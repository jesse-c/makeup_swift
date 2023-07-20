defmodule Makeup.Lexers.SwiftLexer do
  @moduledoc """
  Lexer for the Swift language to be used with the Makeup package.

  Based on the official language reference [1].

  [1] https://docs.swift.org/swift-book/documentation/the-swift-programming-language/aboutthelanguagereference
  """

  import NimbleParsec
  import Makeup.Lexer.Combinators
  import Makeup.Lexer.Groups

  @behaviour Makeup.Lexer

  ###################################################################
  # Step #1: tokenize the input (into a list of tokens)
  ###################################################################

  @inline Application.compile_env(:makeup_html, :inline, false)

  # Lines

  # LF/U+000A
  line_feed = ascii_char([?\n])
  # CR/U+000D
  carriage_return = ascii_char([?\r])

  line_break =
    choice([
      line_feed,
      carriage_return,
      concat(line_feed, carriage_return)
    ])

  # Whitespace
  whitespace_item = [?\r, ?\s, ?\n, ?\f]
  whitespace = whitespace_item |> ascii_string(min: 1) |> token(:whitespace)

  # Literals
  #
  # A literal is the source code representation of a value of a type, such as a number or string.
  #
  # The following are examples of literals:
  #
  # 42               // Integer literal
  # 3.14159          // Floating-point literal
  # "Hello, world!"  // String literal
  # /Hello, .*/      // Regular expression literal
  # true             // Boolean literal

  ## String
  quoted_text_item = utf8_string([], 1)

  quoted_text = quoted_text_item

  string_literal_opening_delimiter = string("\"")

  string_literal_closing_delimiter = string("\"")

  static_string_literal =
    many_surrounded_by(
      quoted_text,
      string_literal_opening_delimiter,
      string_literal_closing_delimiter
    )

  string_literal = static_string_literal |> token(:literal)

  ## nil
  nil_literal = string("nil") |> token(:literal)

  ## Boolean
  boolean_literal = choice([string("true"), string("false")]) |> token(:literal)

  ## Numeric

  ### Integer

  #### Decimal
  decimal_digit = ascii_string([?0..?9], min: 1)
  decimal_literal = times(decimal_digit, min: 1)
  integer_literal = decimal_literal |> token(:number_integer)

  ### Float
  decimal_fraction = concat(string("."), decimal_literal)
  floating_point_literal = concat(decimal_literal, decimal_fraction) |> token(:number_float)

  ## All
  numeric_literal =
    choice([
      floating_point_literal,
      integer_literal
    ])

  ## All
  literal =
    choice([
      nil_literal,
      boolean_literal,
      string_literal,
      numeric_literal
    ])

  # Comments
  comment_text = utf8_string([], 1)

  ## Inline
  inline_comment =
    string("//")
    |> concat(repeat(lookahead_not(line_break) |> utf8_string([], 1)))
    |> token(:comment_single)

  ## Multi-line
  multiline_comment_text = comment_text

  multiline_comment =
    multiline_comment_text
    |> many_surrounded_by("/*", "*/")
    |> token(:comment_multiline)

  # Root

  root_element_combinator =
    choice([
      # Whitespace
      whitespace,
      # Literals
      literal,
      # Comments
      inline_comment,
      multiline_comment
    ])

  @doc false
  def __as_swift_language__({ttype, meta, value}) do
    {ttype, Map.put(meta, :language, :swift), value}
  end

  ##############################################################################
  # Semi-public API: these two functions can be used by someone who wants to
  # embed this lexer into another lexer, but other than that, they are not
  # meant to be used by end-users
  ##############################################################################

  @impl Makeup.Lexer
  defparsec(
    :root_element,
    root_element_combinator |> map({__MODULE__, :__as_swift_language__, []}),
    inline: @inline
  )

  @impl Makeup.Lexer
  defparsec(
    :root,
    repeat(parsec(:root_element)),
    inline: @inline
  )

  ###################################################################
  # Step #2: postprocess the list of tokens
  ###################################################################

  @impl Makeup.Lexer
  def postprocess(tokens, _opts \\ []) do
    tokens
  end

  #######################################################################
  # Step #3: highlight matching delimiters
  #######################################################################

  @impl Makeup.Lexer
  defgroupmatcher(:match_groups, [])

  # Finally, the public API for the lexer
  @impl Makeup.Lexer
  def lex(text, opts \\ []) do
    group_prefix = Keyword.get(opts, :group_prefix, random_prefix(10))
    {:ok, tokens, "", _, _, _} = root(text)

    tokens
    |> postprocess()
    |> match_groups(group_prefix)
  end
end
