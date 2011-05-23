from urllib2 import urlopen
import urllib2
import simplejson as json

url = "http://localhost:3000/emerges"

category = "app-shells"
name = "bash"
version = "4.2_p8-r1"

data = json.dumps({"emerge": {"user": "naota344",
                              "duration": 3200,
                              "buildtime": "2011-05-23T09:10:30Z",
                              "package":{"category": category,
                                         "name": name,
                                         "version": version}}})

req = urllib2.Request(url, data, {"Content-Type": "application/json",
                                  "Accept": "application/json"})
f = urlopen(req)
print f.info()
print f.read()
