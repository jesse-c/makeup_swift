defmodule MakeupSwift.MixProject do
  use Mix.Project

  def project do
    [
      app: :makeup_swift,
      version: "0.0.2",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package(),
      source_url: "https://github.com/jesse-c/makeup_swift",
      homepage_url: "https://github.com/jesse-c/makeup_swift"
    ]
  end

  def application do
    [
      extra_applications: [],
      mod: {Makeup.Lexers.SwiftLexer.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.30.3", only: :dev, runtime: false},
      {:makeup, "~> 1.1"},
      {:nimble_parsec, "~> 1.3"}
    ]
  end

  defp aliases do
    [changelog: ["cmd git cliff -o CHANGELOG.md"]]
  end

  defp description do
    "A Makeup lexer for the Swift language."
  end

  defp package do
    [
      name: "makeup_swift",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jesse-c/makeup_swift"}
    ]
  end
end
