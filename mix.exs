defmodule Bionex.MixProject do
  use Mix.Project

  def project do
    [
      app: :bionex,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nx, ">= 0.4.2"},
      # {:kino, ">= 0.8.1"},
      {:nimble_options, ">= 0.5.2"}
    ]
  end
end
