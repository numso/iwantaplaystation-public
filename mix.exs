defmodule Checker.MixProject do
  use Mix.Project

  def project do
    [
      app: :checker,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Checker.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:httpoison, "~> 1.8"},
      {:oauther, "~> 1.1"},
      {:swoosh, "~> 1.4"},
      {:mail, ">= 0.0.0"},
      {:hackney, "~> 1.17"},
      {:gen_tcp_accept_and_close, "~> 0.1.0"}
    ]
  end

  defp aliases do
    []
  end
end
