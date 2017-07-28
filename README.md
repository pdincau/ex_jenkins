# ExJenkins

**Your Jenkins client written in elixir**

## Installation

```elixir
def deps do
  [{:ex_jenkins, "~> 0.1.1"}]
end
```

In your configuration file add something similar to:

```elixir
config :ex_jenkins,
  host: "localhost",
  protocol: "http", # http or https.  Default is http
  port: "8080",
  username: "username",
  password: "password",
  token: "mytoken"
```

You must as well start `ex_jenkins` in your application list:

```
applications: [:ex_jenkins]
```

## List of Jenkins API you can consume with ExJenkins

With ExJenkins you can consume the following Jenkins endpoints:

* Jenkins: allows you to restart, or toggle quiet mode in your Jenkins installation
* Jobs: you can execute several operations on your jobs (e.g. you can create, start, stop, get status etc)
* Queues: you can retrieve information on your Jenkins queue
* Folders: you can create and delete folders
* Crumb: you can request a Jenkins crumb
