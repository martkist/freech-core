#!/usr/bin/env python2
#
# very simple wrapper for starting freechd and launching the web browser
#
# generates a default rpcpassword, freech.conf file etc.
# may also setup automatic freechd script on desktop login.

try:
    from Tkinter import *
    from tkMessageBox import *
except:
    pass # we will fail later, only on GUI creation
from subprocess import call, check_output
import csv
import operator
import string
import random
import os
import sys
import stat
import socket
import time
import webbrowser
import argparse

configFilename = os.path.expanduser('~/.freech/freech.conf')
startupScript = os.path.expanduser('~/.config/autostart/freechd-startup.desktop')

def passwordGenerator(size=10, chars=string.ascii_lowercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

configOptions = {
    'rpcuser' : 'user',
    'rpcpassword' : passwordGenerator(),
    'rpcallowip' : '127.0.0.1',
    'rpcport' : '28332',
}

def loadConfig():
    try:
        with open(configFilename, "rb") as csvfile:
            reader = csv.reader(csvfile, delimiter='=', escapechar='\\', quoting=csv.QUOTE_NONE)
            for row in reader:
                if len(row) != 2:
                    raise csv.Error("Too many fields on row with contents: "+str(row))
                configOptions[row[0]] = row[1] 
    except:
        pass

def saveConfig():
    configDir = os.path.dirname(configFilename)
    if not os.path.exists(configDir):
        os.makedirs(configDir)
    with open(configFilename, "wb") as csvfile:
        writer = csv.writer(csvfile, delimiter='=', escapechar='\\', quoting=csv.QUOTE_NONE)
        for key, value in sorted(configOptions.items(), key=operator.itemgetter(0)):
                writer.writerow([ key, value])

def get_pid(name):
    try:
        return check_output(["pidof",name])
    except:
        return []

def getBrowser():
    prefList = ['google-chrome', 'chrome', 'chromium']
    for browserName in prefList:
        try:
            return webbrowser.get(browserName)
        except:
            pass
    customPathList = ['/usr/bin/google-chrome']
    for browserExe in customPathList:
        if os.path.exists(browserExe):
            return webbrowser.get(browserExe + ' %s &')
    return webbrowser

def daemon():
    freechdArgs = ["-daemon"]
    systemHtmlDir = '/usr/share/freech/html'
    if os.path.exists(systemHtmlDir):
        freechdArgs += ['-htmldir='+systemHtmlDir]
    try:
        call(["freechd"] + freechdArgs)
    except:
        try:
            freechd = os.path.dirname(os.path.realpath(sys.argv[0])) + "/freechd"
            call([freechd] + freechdArgs)
        except:
            print "running 'freechd' failed. check if installed and PATH is correctly configured"

def launch():
    justLaunched = False
    if not get_pid('freechd'):
        print "launching freechd..."
        daemon()
        justLaunched = True
    
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    daemonUp = False
    while not daemonUp:
        try:
            s.connect(('127.0.0.1', int(configOptions['rpcport'])))
            daemonUp = True
        except:
            print "waiting for freechd initialization..."
            time.sleep(1)

    if justLaunched:
        time.sleep(1) # may prevent useless warning about not connected etc

    print "launching webbrowser..."
    url = "http://" + configOptions['rpcuser'] + ":" + configOptions['rpcpassword']
    url += "@127.0.0.1:" + configOptions['rpcport']
    getBrowser().open_new(url)

def addStartup():
    desktopFile = \
        "[Desktop Entry]\n" \
        "Type=Application\n" \
        "Version=1.0\n" \
        "Name=freechd-startup\n" \
        "Comment=start freechd on login\n" \
        "Terminal=false\n"
    desktopFile += "Exec=" + os.path.realpath(sys.argv[0]) + " --daemon\n"
    autostartDir = os.path.dirname(startupScript)
    if not os.path.exists(autostartDir):
        os.makedirs(os.path.dirname(startupScript))
    open(startupScript,"wb").write(desktopFile)
    st = os.stat(startupScript)
    os.chmod(startupScript, st.st_mode | stat.S_IEXEC)

def removeStartup():
    try:
        os.remove(startupScript)
    except:
        pass

def guiLaunch():
    loadConfig()
    saveConfig()
    launch()
    exit()

def guiAddStartup():
    addStartup()
    showinfo('Ok', 'Startup script added!\nfreechd will start automatically\non next login.')

def guiRemoveStartup():
    removeStartup()
    showinfo('Ok', 'Startup script removed')

def createGui():
    try:
        root = Tk()
    except:
        print 'Module Tkinter not found. Try installing python-tk to use GUI.'
        exit(-1)
    root.title('freech control')
    root.minsize(width=200,height=100)
    Button(text='Launch freech', command=guiLaunch).pack(fill=X)
    Button(text='Add startup script', command=guiAddStartup).pack(fill=X)
    Button(text='Remove startup script', command=guiRemoveStartup).pack(fill=X)
    Button(text='Quit', command=exit).pack(fill=X)
    
    mainloop()

parser = argparse.ArgumentParser()
parser.add_argument("--launch", help="launch freech daemon and browser", action="store_true")
parser.add_argument("--daemon", help="launch freech daemon only", action="store_true")
parser.add_argument("--addstartup", help="add startup script", action="store_true")
parser.add_argument("--removestartup", help="add startup script", action="store_true")
parser.add_argument("--gui", help="open freech control gui", action="store_true")
args = parser.parse_args()

if args.launch or args.daemon:
    loadConfig()
    saveConfig()

if args.launch:
    launch()
elif args.daemon:
    daemon()
elif args.addstartup:
    addStartup()
elif args.removestartup:
    removeStartup()
else:
    createGui()

