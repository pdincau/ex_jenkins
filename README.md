# ExJenkins

**Your Jenkins client written in elixir**

## Installation

```elixir
def deps do
  [{:ex_jenkins, "~> 0.1.0"}]
end
```

In your configuration file add something similar to:

```elixir
config :ex_jenkins,
  host: "localhost",
  port: "8080",
  username: "username",
  password: "password",
  token: "mytoken"
```
