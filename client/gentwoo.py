#!/usr/bin/python

from urllib2 import urlopen
import urllib2
import simplejson as json
import sys
import os
import re
import datetime
import time

url = "http://localhost:3000/emerges"
user = "naota344"
token = "c50a5090f305b82ab6a5"

uploadLog = True
uploadErorrLog = True
cleanLog = True 

portagelog = "/var/log/emerge.log"
logparse = 4096

def parsePackage(package):
    m = re.match(r'^(.+)/(.+)$', package)
    (ctg, rest) = m.groups()
    m = re.match(r'^([-0-9A-Za-z0-9_+]+)-(.+)$', rest)
    return (ctg, m.group(1), m.group(2))

def convTime(tm):
    return datetime.datetime.utcfromtimestamp(tm).strftime("%Y-%m-%dT%H:%M:%SZ")

def sendQuery(package, end, duration, logfile):
    (category, name, version) = parsePackage(package)
    log = ""
    if logfile: log = open(logfile).read()
    data = json.dumps({"emerge": {"duration": duration,
                                  "buildtime": convTime(end),
                                  "log": log, "errorlog": ""},
                       "package":{"category": category,
                                  "name": name,
                                  "version": version},
                       "user": user,
                       "token": token})
    urlopen(urllib2.Request(url, data, {"Content-Type": "application/json",
                                        "Accept": "application/json"}))

def sendErrQuery(package, tm, logfile, errfile):
    (category, name, version) = parsePackage(package)
    data = json.dumps({"emerge": {"duration": 0,
                                  "buildtime": tm,
                                  "log": open(logfile).read(),
                                  "errorlog": open(errfile).read()},
                       "package":{"category": category,
                                  "name": name,
                                  "version": version},
                       "user": user,
                       "token": token})
    urlopen(urllib2.Request(url, data, {"Content-Type": "application/json",
                                        "Accept": "application/json"}))

def searchLog(package):
    regBeg = re.compile(r'^(\d+):  >>> emerge \(\d+ of \d+\) '+re.escape(package)+' to ')
    regEnd = re.compile(r'^(\d+):  ::: completed emerge \(\d+ of \d+\) '+re.escape(package)+' to ')
    begTime = None
    endTime = None
    with open(portagelog) as plf:
        plf.seek(-logparse, os.SEEK_END)
        lines = plf.readlines()
        for l in  reversed(lines[1:]):
            if not endTime:
                m = regEnd.match(l)
                if m: endTime = int(m.group(1))
                continue
            m = regBeg.match(l)
            if m: 
                begTime = int(m.group(1))
                break
    return (begTime, endTime)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)
    package = sys.argv[1]
    if len(sys.argv) > 2 and uploadLog:
        logfile = sys.argv[2]
    else:
        logfile = None
    if os.fork() != 0: os._exit(0)
    for x in range(10):
        time.sleep(1)
        (beg, end)=searchLog(package)
        if beg and end: break
    if not beg or not end: 
        if not logfile or not uploadErorrLog:
            sys.exit(0)
        with open(logfile) as plf:
            error = False
            reglogfile=re.compile(r"^The complete build log is located at '(.+)'.$")
            for l in plf:
                if error:
                    m = reglogfile.match(l)
                    if m:
                        tm = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
                        sendErrQuery(package, tm, logfile, m.group(1))
                        if cleanLog: os.remove(logfile)
                        sys.exit(0)
                else:
                    if l.startswith("ERROR: "): error=True
        sys.exit(0)
    sendQuery(package, end, end-beg, logfile)
    if logfile and cleanLog: os.remove(logfile)
