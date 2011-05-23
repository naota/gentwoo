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
    data = json.dumps({"emerge": {"duration": duration,
                                  "buildtime": convTime(end),
                                  "log": open(logfile).read()},
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
    for x in range(10):
        time.sleep(1)
        (beg, end)=searchLog(package)
        if beg and end: break
    if not beg or not end: sys.exit(2)
    sendQuery(package, end, end-beg, logfile)
    if logfile and cleanLog:
        os.remove(logfile)
