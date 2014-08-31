(function() {
	
	droid.UDP_bind = function(port) {
		var err = droid._UDP_bind(port);
		if (err) throw new Error(err);
	};
	
	droid.UDP_startReceiver = function(recv_fname, err_fname) {
		var err = droid._UDP_startReceiver(recv_fname, err_fname);
		if (err) throw new Error(err);
	};
	
	droid.UDP_send = function(addr, port, data) {
		var err = droid._UDP_send(addr, port, data);
		if (err) throw new Error(err);
	};
	
})();
