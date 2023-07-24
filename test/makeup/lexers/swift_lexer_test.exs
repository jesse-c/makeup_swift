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

    test "identifier for a reserved word in backticks" do
      assert SwiftLexer.lex(~s(`class`)) == [{:name, %{language: :swift}, '`class`'}]
    end

    test "keyword declaration" do
      assert SwiftLexer.lex(~s(enum)) == [{:keyword, %{language: :swift}, "enum"}]
    end

    test "keyword statement" do
      assert SwiftLexer.lex(~s(continue)) == [{:keyword, %{language: :swift}, "continue"}]
    end

    test "keyword expression" do
      assert SwiftLexer.lex(~s(await)) == [{:keyword, %{language: :swift}, "await"}]
    end

    test "keyword type" do
      assert SwiftLexer.lex(~s(catch)) == [{:keyword, %{language: :swift}, "catch"}]
    end

    test "keyword number sign" do
      assert SwiftLexer.lex(~s(#available)) == [{:keyword, %{language: :swift}, "#available"}]
    end

    test "punctuation single character" do
      assert SwiftLexer.lex(~s(?)) == [{:punctuation, %{language: :swift}, 63}]
    end

    test "punctuation multiple characters" do
      assert SwiftLexer.lex(~s(->)) == [{:punctuation, %{language: :swift}, "->"}]
    end

    test "operator infix" do
      assert SwiftLexer.lex(~s(+)) == [{:operator, %{language: :swift}, 43}]
    end

    test "type Self" do
      assert SwiftLexer.lex(~s(Self)) == [{:keyword_type, %{language: :swift}, "Self"}]
    end

    test "type Any" do
      assert SwiftLexer.lex(~s(Any)) == [{:keyword_type, %{language: :swift}, "Any"}]
    end
  end
end
