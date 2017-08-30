defmodule ExJenkins.Mixfile do
  use Mix.Project

  @description """
      Your Jenkins client written in elixir
  """

  def project do
    [app: :ex_jenkins,
     version: "0.1.3",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: @description,
     package: package(),
     deps: deps(),
     source_url: "https://github.com/pdincau/ex_jenkins",
     aliases: [test: "test --no-start"]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger],
     mod: {ExJenkins, []},
    applications: [:httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:httpoison, "~> 0.13.0"},
     {:poison, "~> 3.1 or ~> 2.0"},
     {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [ maintainers: ["pdincau, chazsconi"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/pdincau/ex_jenkins"} ]
    end
end
