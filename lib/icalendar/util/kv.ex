defmodule ICalendar.Util.KV do
  @moduledoc """
  Build ICalendar key-value strings
  """

  @doc ~S"""
    iex> ICalendar.Util.KV.build("foo", "bar")
    "foo:bar\n"

    iex> ICalendar.Util.KV.build("foo", nil)
    ""
  """
  def build(_, nil) do
    ""
  end
  def build(key, value) do
    "#{key}:#{value}\n"
  end
end
