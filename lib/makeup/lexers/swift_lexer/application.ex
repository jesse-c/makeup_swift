defmodule Makeup.Lexers.SwiftLexer.Application do
  @moduledoc false
  use Application

  alias Makeup.Registry
  alias Makeup.Lexers.SwiftLexer

  def start(_type, _args) do
    Registry.register_lexer(
      SwiftLexer,
      options: [],
      names: ["swift"],
      extensions: ["swift"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
