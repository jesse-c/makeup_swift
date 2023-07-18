defmodule Makeup.Lexers.SwiftLexer do
  @moduledoc """
  Lexer for the Swift language to be used
  with the Makeup package.
  """

  import NimbleParsec
  import Makeup.Lexer.Combinators
  import Makeup.Lexer.Groups

  @behaviour Makeup.Lexer

  ###################################################################
  # Step #1: tokenize the input (into a list of tokens)
  ###################################################################

  @inline Application.compile_env(:makeup_html, :inline, false)

  root_element_combinator = string("hello")

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
