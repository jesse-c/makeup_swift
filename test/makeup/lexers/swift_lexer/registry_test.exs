defmodule Makeup.Lexers.SwiftLexer.RegistryTest do
  use ExUnit.Case, async: true

  alias Makeup.Registry
  alias Makeup.Lexers.SwiftLexer

  describe "the Swift lexer has successfully registered itself:" do
    test "language name" do
      assert {:ok, {SwiftLexer, []}} == Registry.fetch_lexer_by_name("swift")
    end

    test "file extension" do
      assert {:ok, {SwiftLexer, []}} == Registry.fetch_lexer_by_extension("swift")
    end
  end
end
