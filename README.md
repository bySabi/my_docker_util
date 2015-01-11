my docker util
==========

Install:

```
	curl -L -o /tmp/install.sh https://raw.github.com/bySabi/my_docker_util/master/install.sh
	chmod +x /tmp/install.sh && sudo /tmp/install.sh
```

Install nsenter:

```
	sudo bash -c "docker run --rm jpetazzo/nsenter cat /nsenter > /usr/local/bin/nsenter && chmod +x /usr/local/bin/nsenter"
```
