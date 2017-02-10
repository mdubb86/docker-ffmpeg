import sys
import os
import shlex
import signal
import subprocess

# Forward signals to ffmpeg
def signal_handler(signal, frame):
    print 'Forwarding signal ' + signal + ' to ffmpeg'
    p.send_signal(signal)
signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGHUP, signal_handler)
signal.signal(signal.SIGABRT, signal_handler)
signal.signal(signal.SIGQUIT, signal_handler)
signal.signal(signal.SIGCONT, signal_handler)

args = shlex.split(os.environ['CMD'])
print 'Args', list(args))
p = subprocess.Popen(['ffmpeg'] + args)
p.wait()


