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

  ###############################################################################
  # Step #1: tokenize the input (into a list of tokens)                         #
  ###############################################################################

  @inline Application.compile_env(:makeup_html, :inline, false)

  # -----------------------------------------------------------------------------
  # Lines                                                                       |
  # -----------------------------------------------------------------------------

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

  # -----------------------------------------------------------------------------
  # Whitespace                                                                  |
  # -----------------------------------------------------------------------------

  whitespace_item = [?\r, ?\s, ?\n, ?\f]
  whitespace = whitespace_item |> ascii_string(min: 1) |> token(:whitespace)

  # -----------------------------------------------------------------------------
  # Literals                                                                    |
  # -----------------------------------------------------------------------------
  #                                                                             |
  # A literal is the source code representation of a value of a type, such as a |
  # number or string.                                                           |
  #                                                                             |
  # The following are examples of literals:                                     |
  #                                                                             |
  # 42               // Integer literal                                         |
  # 3.14159          // Floating-point literal                                  |
  # "Hello, world!"  // String literal                                          |
  # /Hello, .*/      // Regular expression literal                              |
  # true             // Boolean literal                                         |
  # -----------------------------------------------------------------------------

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

  # ------------------------------------------------------------------------------
  # Comments                                                                     |
  # ------------------------------------------------------------------------------

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

  # -----------------------------------------------------------------------------
  # Identifiers                                                                 |
  # -----------------------------------------------------------------------------

  backtick = utf8_char([?`])

  identifier_head = utf8_char([?a..?z, ?A..?Z, ?_])

  identifier_character = choice([identifier_head, utf8_char([?0..?9])])

  identifier_characters = repeat(identifier_character)

  identifier =
    optional(backtick)
    |> concat(identifier_head)
    |> concat(optional(identifier_characters))
    |> concat(optional(backtick))
    |> token(:name)

  # -----------------------------------------------------------------------------
  # Keywords                                                                    |
  # -----------------------------------------------------------------------------

  @keywords_declarations ~w[associatedtype class deinit enum extension fileprivate func import init inout internal let open operator private precedencegroup protocol public rethrows static struct subscript typealias var]
  @keywords_statements ~w[break case catch continue default defer do else fallthrough for guard if in repeat return throw switch where while]
  @keywords_expressions_and_types ~w[Any as await catch false is nil rethrows self Self super throw throws true try]
  @keywords_begin_with_a_number_sign ~w[#available #colorLiteral #elseif #else #endif #if #imageLiteral #keyPath #selector #sourceLocation]
  @keywords List.flatten([
              @keywords_declarations,
              @keywords_statements,
              @keywords_expressions_and_types,
              @keywords_begin_with_a_number_sign
            ])

  keyword =
    @keywords
    |> word_from_list()
    # A naïve way to avoid identifiers of reserved keywords
    |> lookahead_not(backtick)
    |> token(:keyword)

  # -----------------------------------------------------------------------------
  # Punctuation                                                                 |
  # -----------------------------------------------------------------------------

  punctuation =
    choice([
      ascii_char([?(, ?), ?{, ?}, ?[, ?], ?., ?,, ?:, ?;, ?=, ?@, ?#, ?&, ?`, ??, ?!]),
      string("->")
    ])
    |> token(:punctuation)

  # -----------------------------------------------------------------------------
  # Operators                                                                   |
  # -----------------------------------------------------------------------------

  operator_head = ascii_char([?/, ?=, ?-, ?+, ?!, ?*, ?%, ?<, ?>, ?&, ?|, ?^, ?~, ??])
  operator_character = operator_head
  operator_characters = operator_character |> concat(optional(operator_character))
  operator = operator_head |> concat(optional(operator_characters)) |> token(:operator)
  infix_operator = operator
  prefix_operator = operator
  postfix_operator = operator

  # -----------------------------------------------------------------------------
  # Root                                                                        |
  # -----------------------------------------------------------------------------

  root_element_combinator =
    choice([
      # Whitespace
      whitespace,
      # Literals
      literal,
      # Comments
      inline_comment,
      multiline_comment,
      # Keywords,
      keyword,
      # Identifiers
      identifier,
      # Punctuation
      punctuation,
      # Operators
      infix_operator,
      prefix_operator,
      postfix_operator
    ])

  # Semi-public API: these two functions can be used by someone who wants to
  # embed this lexer into another lexer, but other than that, they are not
  # meant to be used by end-users

  @doc false
  def __as_swift_language__({ttype, meta, value}) do
    {ttype, Map.put(meta, :language, :swift), value}
  end

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

  ###############################################################################
  # Step #2: postprocess the list of tokens                                     #
  ###############################################################################

  defp postprocess_helper(tokens)

  defp postprocess_helper([]), do: []

  defp postprocess_helper([{:name, attrs, text} | tokens])
       when text in ['Int', 'UInt', 'UInt32', 'UInt64', 'Double', 'String'],
       do: [{:keyword_type, attrs, text} | postprocess_helper(tokens)]

  defp postprocess_helper([{:keyword, attrs, text} | tokens]) when text in ["Any", "Self"],
    do: [{:keyword_type, attrs, text} | postprocess_helper(tokens)]

  # Otherwise, don't do anything with the current token and go to the next token.
  defp postprocess_helper([token | tokens]), do: [token | postprocess_helper(tokens)]

  @impl Makeup.Lexer
  def postprocess(tokens, _opts \\ []), do: postprocess_helper(tokens)

  ###############################################################################
  # Step #3: highlight matching delimiters                                      #
  ###############################################################################

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
