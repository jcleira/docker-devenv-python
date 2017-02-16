# Dockerized python development environment
![Docker python environment](http://i.imgur.com/yKjbbdL.png)

This repository contains my personal dockerized development environment for pythn.

Usage:

```bash
docker run -t -i -v /home/<user>/.ssh:/home/dev/.ssh -v /home/<user>/Code:/home/dev/Code --net=host jcorral/docker-devenv-python
```
