#!/usr/bin/python

from urllib2 import urlopen
import urllib2
import simplejson as json
import sys
import os
import re
import datetime
import time
from portage.util import getconfig

class Query:
    def __init__(self, config, package, begin, end, logfile):
        self.config = config
        self.package = package
        self.beginTime = begin
        self.endTime = end
        self.logfile = logfile
    def getErrorLog(self):
        if not self.logfile: return None
        if not self.config['UPLOAD_ERROR_LOG']: return None
        with open(self.logfile) as plf:
            error = False
            reglogfile=re.compile(r"^The complete build log is located at '(.+)'.$")
            for l in plf:
                if error:
                    m = reglogfile.match(l)
                    if not m: continue
                    return m.group(1)
                elif l.startswith("ERROR: "): error=True
        return None
    def queryData(self):
        protocolVersion = "1"
        (category, name, version) = parsePackage(self.package)
        error = not (self.beginTime and self.endTime)
        (log, errorlog) = ('', '')

        if self.endTime:
            buildtime = convTime(self.endTime)
        else:
            buildtime = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

        if self.logfile: log = open(self.logfile).read()
        if error:
            duration = 0
            errorlogfile = self.getErrorLog()
            if errorlogfile: errorlog = open(errorlogfile).read()
        else:
            duration = self.endTime - self.beginTime

        return {"emerge": {"duration": duration,
                           "buildtime": buildtime,
                           "log": log,
                           "errorlog": errorlog},
                "package":{"category": category,
                           "name": name,
                           "version": version},
                "user":  self.config['USER'],
                "token": self.config['TOKEN'],
                "version": protocolVersion}
    def send(self):
        data = json.dumps(self.queryData())
        f = urlopen(urllib2.Request(self.config['URL'],
                                    data, {"Content-Type": "application/json",
                                           "Accept": "application/json"}))
        result = json.loads(f.read())
        ret = result['result']
        info = result['info']
        return (ret, info)

def loadConfig(configfile):
    config = getconfig(configfile)

    for key in config:
      if config[key].lower == 'true':
        config[key] = True
      elif config[key].lower == 'false':
        config[key] = False
      elif config[key].isdigit():
        config[key] = int(config[key])

    return config

def parsePackage(package):
    m = re.match(r'^(.+)/(.+)$', package)
    (ctg, rest) = m.groups()
    m = re.match(r'^([-0-9A-Za-z0-9_+]+)-(.+)$', rest)
    return (ctg, m.group(1), m.group(2))

def convTime(tm):
    return datetime.datetime.utcfromtimestamp(tm).strftime("%Y-%m-%dT%H:%M:%SZ")

def searchLog(package, config):
    regBeg = re.compile(r'^(\d+):  >>> emerge \(\d+ of \d+\) '+re.escape(package)+' to ')
    regEnd = re.compile(r'^(\d+):  ::: completed emerge \(\d+ of \d+\) '+re.escape(package)+' to ')
    begTime = None
    endTime = None
    with open(config['PORTAGE_LOG']) as plf:
        plf.seek(-config['LOG_PARSE'], os.SEEK_END)
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

def loadArgument(config):
    if len(sys.argv) < 2:
        return (None, None)
    elif len(sys.argv) > 2 and config['UPLOAD_LOG']:
        return (sys.argv[1], sys.argv[2])
    else:
        return (sys.argv[1], None)

def trySearchLog(package, config):
    for x in range(10):
        time.sleep(1)
        (beg, end)=searchLog(package, config)
        if beg and end: return (beg, end)
    return (None, None)

if __name__ == "__main__":
    config = loadConfig('/etc/gentwoo.conf')
    if config is None:
      sys.exit(1)

    (package, logfile) = loadArgument(config)
    if package is None:
        sys.exit(1)

    if os.fork() != 0: os._exit(0)

    (begin, end) = trySearchLog(package, config)
    query = Query(config, package, begin, end, logfile)
    (result, info) = query.send()
    if info !='': print "Message from GenTwoo server: %s" % info
    if logfile and config['CLEAN_LOG']:
        os.remove(logfile)
