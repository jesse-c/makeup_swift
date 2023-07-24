defmodule Makeup.Lexers.SwiftLexerTest do
  use ExUnit.Case, async: false

  alias Makeup.Lexers.SwiftLexer

  describe "lex/1" do
    test "inline comment" do
      assert SwiftLexer.lex(~s(// Hello, World! program\n)) ==
               [
                 {
                   :comment_single,
                   %{language: :swift},
                   [
                     "//",
                     " ",
                     "H",
                     "e",
                     "l",
                     "l",
                     "o",
                     ",",
                     " ",
                     "W",
                     "o",
                     "r",
                     "l",
                     "d",
                     "!",
                     " ",
                     "p",
                     "r",
                     "o",
                     "g",
                     "r",
                     "a",
                     "m"
                   ]
                 },
                 {:whitespace, %{language: :swift}, "\n"}
               ]
    end

    test "multi-line comment" do
      assert SwiftLexer.lex(~s(/* test */\n)) == [
               {:comment_multiline, %{language: :swift},
                [
                  {:punctuation, %{}, "/*"},
                  " ",
                  "t",
                  "e",
                  "s",
                  "t",
                  " ",
                  {:punctuation, %{}, "*/"}
                ]},
               {:whitespace, %{language: :swift}, "\n"}
             ]
    end

    test "true boolean literal" do
      assert SwiftLexer.lex(~s(true)) == [{:literal, %{language: :swift}, "true"}]
    end

    test "false boolean literal" do
      assert SwiftLexer.lex(~s(false)) == [{:literal, %{language: :swift}, "false"}]
    end

    test "string literal" do
      assert SwiftLexer.lex(~s("hello world")) == [
               {
                 :literal,
                 %{language: :swift},
                 ["\"", "h", "e", "l", "l", "o", " ", "w", "o", "r", "l", "d", "\""]
               }
             ]
    end

    test "nil literal" do
      assert SwiftLexer.lex(~s(nil)) == [
               {
                 :literal,
                 %{language: :swift},
                 "nil"
               }
             ]
    end

    test "integer literal" do
      assert SwiftLexer.lex(~s(59)) == [{:number_integer, %{language: :swift}, "59"}]
    end

    test "floating point literal" do
      assert SwiftLexer.lex(~s(28.04)) == [
               {:number_float, %{language: :swift}, ["28", ".", "04"]}
             ]
    end

    test "identifier starting with alpha" do
      assert SwiftLexer.lex(~s(age)) == [{:name, %{language: :swift}, 'age'}]
    end

    test "identifier starting with underscore" do
      assert SwiftLexer.lex(~s(_gender)) == [{:name, %{language: :swift}, '_gender'}]
    end
  end
end
