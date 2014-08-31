# coding: utf-8
from RPIO import PWM
import socket

PORT = 25678

sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
sock.bind(("0.0.0.0", PORT))

servo = PWM.Servo()
#servo.stop_servo(17)
#CHANNEL = 0
#PWM.set_loglevel(PWM.LOG_LEVEL_DEBUG)
#PWM.setup()
#PWM.init_channel(CHANNEL)
#PWM.print_channel(CHANNEL)
#PWM.add_channel_pulse(CHANNEL, 0, 0, 150)


def handle_ping(sock, addr, msg):
	print "pinged, " + msg
	sock.sendto("P"+msg, addr)

def handle_servo(sock, addr, msg):
	gpio_id = int(msg[:2])
	value = int(msg[2:]) * 10
	print "servo %dus on GPIO%d" % (value, gpio_id)
	servo.set_servo(gpio_id, value)
	#PWM.clear_channel_gpio(CHANNEL, gpio_id)
	#PWM.clear_channel(CHANNEL)
	#PWM.add_channel_pulse(CHANNEL, gpio_id, 0, value)

handlers = {
	'P': handle_ping,
	'S': handle_servo,
}

while True:
	data, addr = sock.recvfrom(1024)
	code, msg = data[0], data[1:]
	print "addr: ", addr
	
	if code in handlers:
		handlers[code](sock, addr, msg)
	else:
		print "Unknown code: " + code

