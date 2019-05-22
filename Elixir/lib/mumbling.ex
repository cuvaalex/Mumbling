defmodule Mumbling do
  @moduledoc """
  Documentation for Mumbling.
  """
  require Logger

  def accum(text) do
    text
    |> String.graphemes
    |> Enum.with_index
    |> Enum.map(&serialize/1)
    |> Enum.join("-")
  end

  def serialize({letter, index}) do
    letter
    |> String.duplicate(index+1)
    |> String.capitalize
  end
end