defmodule ExSentry.Mixfile do
  use Mix.Project

  def project do
    [app: :exsentry,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test
     ],
     deps: deps]
  end

  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpotion, :timex, :plug],
     mod: {ExSentry, []}]
  end

  defp deps do
    [
      {:fuzzyurl, "~> 0.8.1"},
      {:uuid, "~> 1.1"},
      {:timex, "~> 0.19.2"},
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.2"},
      {:httpotion, "~> 2.1.0"},
      {:poison, "~> 1.5.0"},
      {:plug, "~> 1.0"},
      {:ex_spec, "~> 1.0.0", only: :test},
      {:mock, "~> 0.1.1", only: :test},
      {:excoveralls, "~> 0.4.3", only: :test},
      {:mock, "~> 0.1.1", only: :test},
    ]
  end
end
