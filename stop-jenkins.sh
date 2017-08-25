#!/bin/bash
if [ "$(docker ps -q -f name=ex_jenkins_jenkins)" ]; then
  echo "Stopping existing Jenkins"
  docker stop ex_jenkins_jenkins
else
  echo "Docker container not running"
fi
