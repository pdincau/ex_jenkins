# ExJenkins


[![Hex.pm](https://img.shields.io/hexpm/v/ex_jenkins.svg)](https://hex.pm/packages/ex_jenkins)

**Your Jenkins client written in elixir**


ExJenkins is client to consume the Jenkins API.


## Installation

```elixir
def deps do
  [{:ex_jenkins, "~> 0.1.2"}]
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

If you want to know more on using ExJenkins you may read the [online documentation][docs].

You can also build the docs on your machine with:

```bash
mix docs
```

## Testing

The tests use a real Jenkins instance that is created in a local Docker container.

To run the tests you need to have Docker installed.  This should work on both a Mac and Linux, although
it will not work on Windows.

Running `mix test` starts the Jenkins container (first pulling the image if necessary),
waits for it to be ready (can take around 20 seconds), and then
runs the tests against it.

Once the tests complete, the container is stopped and removed.

The container starts on port 8080 so you need to ensure that this is not being used by anything else.

[docs]: https://hexdocs.pm/ex_jenkins
