#!/usr/bin/perl

$BASE_PATH = "./platforms/android";
$SRC = "$BASE_PATH/src";
$BIN = "$BASE_PATH/bin";
$OBJ = "$BASE_PATH/obj";
$RES = "$BASE_PATH/res";
$ASSETS = "$BASE_PATH/assets";
$ANDROID_MANIFEST = "$BASE_PATH/AndroidManifest.xml";
$CORDOVA_LIB_SRC = "$BASE_PATH/CordovaLib/src";


sub p {
	print "@_\n";
}

sub read_all {
	local $/;
	my $fname = shift;
	open(my $fh, $fname) or die "Can't read file $fname [$!]\n";
	my $data = <$fh>;
	close $fh;
	return $data;
}

sub list_dir {
	my $dirname = shift;
	opendir ($dh, $dirname) or die "Can't read directory $dirname [$!]\n";
	my @dirs = readdir $dh;
	close $dh;
	return @dirs;
}

sub try_find {
	my $orig_path = shift;
	unless (-e $orig_path) {
		my ($where, $what) = $orig_path=~/(.*)\/([^\/]*)/;
		die "Couldn't find '$what' in '$where'!\n";
	}
	$orig_path;
}

sub from_file {
	my ($fname, $name, $example) = @_;
	my @res = read_all($fname) =~ /$name="([^"]+)"/;
	die "Expected $fname to contain someting like\n".
	    "  $name=\"$example\"\n".
	    "  but it didn't." unless $res[0];
	$res[0];
}

sub from_manifest {
	from_file $ANDROID_MANIFEST, shift, shift;
}

sub _mkdir {
	my $path = shift;
	unless (-d $path) {
		mkdir $path or die "Couldn't create directory $path [$!]";
	}
}

$ANDROID_HOME = $ENV{ANDROID_HOME}
	or die "Please set ANDROID_HOME pointing to android sdk!\n".
	       "Like: /home/user/android/sdk\n".
	       "Or:   /home/user/android/sdk/tools\n";
$ANDROID_HOME =~ s/\/tools\/?$//;

$BUILD_TOOLS = "$ANDROID_HOME/build-tools";

my @dirs = sort{$b cmp $a}grep{$_}map{$_=~/android-(.+)$/}list_dir($BUILD_TOOLS);
$TOOLS_VERSION = $dirs[0]
	or die "Searched in $BUILD_TOOLS for directories like 'android-4.3.2'\n".
	       "  but was unable to find any.";

$TARGET_VERSION = from_manifest "android:targetSdkVersion", "number";
$MAIN_CLASS = from_manifest "activity[^>]+android:name", ".MainActivity"; $MAIN_CLASS =~ s/^\.//;
$LABEL = $MAIN_CLASS; #$LABEL = from_file "res/values/strings.xml", #from_manifest "android:label", "AppLabel";
$PACKAGE = from_manifest "package", "com.package.name";

$AAPT        = try_find "$ANDROID_HOME/build-tools/android-$TOOLS_VERSION/aapt";
$DX          = try_find "$ANDROID_HOME/build-tools/android-$TOOLS_VERSION/dx";
$ANDROID_JAR = try_find "$ANDROID_HOME/platforms/android-19/android.jar";
$ADB         = try_find "$ANDROID_HOME/platform-tools/adb";


my %h = (
	'pack' => sub {
		print "Packing...\n";
		print `$AAPT package -f -m -S $RES -M $ANDROID_MANIFEST -I $ANDROID_JAR -J $SRC`;
	},
	'compile' => sub {
		print "Compiling...\n";
		my $jars = `find $SRC | grep "\.java\$"`;
		$jars .= `find $CORDOVA_LIB_SRC | grep "\.java\$"`;
		$jars =~ s/\n/ /g;
		_mkdir $OBJ;
		print `javac -source 1.7 -target 1.7 -d $OBJ -cp $ANDROID_JAR -sourcepath $SRC $jars`;
	},
	'dex' => sub {
		print "Dexing...\n";
		_mkdir $BIN;
		print `$DX --dex --output=$BIN/classes.dex $OBJ`;
	},
	'www' => sub {
		print "Prepearing www folder...\n";
		_mkdir "$ASSETS";
		`rm -r $ASSETS/www/*`;
		`cp $BASE_PATH/platform_www/cordova.js $ASSETS/www/`;
		`cp -r ./www $ASSETS`;
	},
	'apk' => sub {
		print "Generating apk...\n";
		_mkdir $BIN;
		`rm -f $BIN/*.apk`;
		print `$AAPT package -f -S $RES -M $ANDROID_MANIFEST -I $ANDROID_JAR -F $BIN/$LABEL.unsigned.apk -A $ASSETS $BIN`;
	},
	'keystore' => sub {
		print "Generating keystore...\n";
		print `keytool -genkey -validity 10000 -dname "CN=AndroidDebug, O=Android, C=US" -keystore ./$LABEL.keystore -storepass android -keypass android -alias androiddebugkey -keyalg RSA -v -keysize 2048`;
	},
	'sign' => sub {
		print "Signing...\n";
		print `jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore ./$LABEL.keystore -storepass android -keypass android -signedjar $BIN/$LABEL.signed.apk $BIN/$LABEL.unsigned.apk androiddebugkey`;
	},
	'clean' => sub {
		print "Cleanup...\n";
		my $package_path = $PACKAGE; $package_path =~ s/\./\//g;
		`rm -f $SRC/$package_path/R.java`;
		`rm -f -r $OBJ/*`;
		`rm -f $BIN/classes.dex`;
		`rm -f $BIN/*.apk`;
	},
	'uninstall' => sub {
		print "Uninstalling...\n";
		print my $res = `$ADB uninstall $PACKAGE`;
		die if $res =~ /Failure/;
	},
	'install' => sub {
		print "Installing...\n";
		print my $res = `$ADB install -r $BIN/$LABEL.signed.apk`;
		die if $res =~ /Failure/;
	},
	'start' => sub {
		print "Starting...\n";
		print `$ADB shell am start $PACKAGE/$PACKAGE.$MAIN_CLASS`;
	}
);


map{
	$h{$_}();
	die if $?;
}(@ARGV);

