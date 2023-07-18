defmodule MakeupSwift.MixProject do
  use Mix.Project

  def project do
    [
      app: :makeup_swift,
      version: "0.0.1",
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
      {:makeup, "~> 1.1"},
      {:nimble_parsec, "~> 1.3"}
    ]
  end
end
