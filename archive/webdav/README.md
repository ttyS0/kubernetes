## Retired Config

This configuration is retired. I'm a big fan of [DEVONthink](https://www.devontechnologies.com/products/devonthink/overview.html), and used this webdav instance to be the synchronizatoin store for my DEVONthink databases. A couple of revisions ago, they added iCloud sync support, and since I already have a lot of iCloud storage available there wasn't much incentive to continue to run my own webdav instance.

The reason I used Apache  HTTPD for webdav instead of nginx is because DEVONthink utilized some webdav features that didn't exist in the nginx implementation. The nice bit was, thanks to ingress support in K8s, I was able to hang a `/webdav` URI off of my primary domain URL, and throw that to the webdav instance. 

