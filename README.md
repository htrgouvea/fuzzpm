# Lab CVE-2021-41773

Container lab to play/learn with CVE-2021-41773


File disclosure:

```
$ docker build -t apache-default default_conf
$ docker run -dit --name apache-app -p 81:80 apache-default
```

RCE  (CGI enabled):

```
$ docker build -t apache-cgi cgi_mod_enable
$ docker run -dit --name apache-lab -p 82:80 apache-cgi
```
