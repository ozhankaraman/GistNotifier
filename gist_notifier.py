#!/usr/bin/python

gist_username="zebrastack"

import urllib2
import json
import os

cachefilepath = "/tmp/gist_cache"

gist_url = "https://api.github.com/users/" + gist_username + "/gists"

req = urllib2.Request(gist_url)
opener = urllib2.build_opener()
f = opener.open(req)
json = json.loads(f.read())

#Search cache file for new gists
for d in json:
    #print(d['created_at'], d['url'], d['id'])
    find_result=open(cachefilepath, 'r').read().find(d['id'])
    if find_result == -1:
        print("New Gist Found and its URL: %s" % d['html_url'])

#Update cache file
f = open(cachefilepath, "w+")
for d in json:
    f.write("%s\n" % d['id'])
f.close
