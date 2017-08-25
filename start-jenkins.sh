#!/bin/bash
./stop-jenkins.sh
echo "Starting Jenkins"
docker run -p 8080:8080 -d \
  -v $PWD/docker/basic-security.groovy:/var/jenkins_home/init.groovy.d/basic-security.groovy \
  --name ex_jenkins_jenkins \
  --rm \
  jenkins/jenkins:lts
