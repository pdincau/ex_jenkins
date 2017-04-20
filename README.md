# ExJenkins

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_jenkins` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ex_jenkins, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_jenkins](https://hexdocs.pm/ex_jenkins).

curl -v -X POST -H "Jenkins-Crumb:ff3d482de655908706a67bb53eb3b2a0" "http://localhost:8080/job/testjob/build?token=mytoken&cause=Starte+With+ExJenkins" --user pdincau:pdincau
curl -v  --user pdincau:pdincau 'http://localhost:8080//crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'
