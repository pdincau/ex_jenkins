#!groovy

import jenkins.model.*
import hudson.security.*
import hudson.security.csrf.DefaultCrumbIssuer

def instance = Jenkins.getInstance()

println "--> creating local user 'admin'"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin','password')
instance.setSecurityRealm(hudsonRealm)

println "--> Enabling Crumb server"
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
instance.save()
