defprotocol ICalendar.Value do
  @fallback_to_any true
  def to_ics(data)
end

alias ICalendar.Value

defimpl Value, for: BitString do
  def to_ics(x) do
    x
    |> String.replace(~S"\n", ~S"\\n")
    |> String.replace("\n", ~S"\n")
  end
end

defimpl Value, for: Tuple do
  defmacro elem2(x, i1, i2) do
    quote do
      unquote(x) |> elem(unquote(i1)) |> elem(unquote(i2))
    end
  end

  @doc """
  This macro is used to establish whether a tuple is in the Erlang Timestamp
  format (`{{year, month, day}, {hour, minute, second}}`).
  """
  defmacro is_datetime_tuple(x) do
    quote do
      # Year
      # Month
      # Day
      # Hour
      # Minute
      # Second
      unquote(x) |> elem2(0, 0) |> is_integer and
        unquote(x) |> elem2(0, 1) |> is_integer and
        unquote(x) |> elem2(0, 1) <= 12 and
        unquote(x) |> elem2(0, 1) >= 1 and
        unquote(x) |> elem2(0, 2) |> is_integer and
        unquote(x) |> elem2(0, 2) <= 31 and
        unquote(x) |> elem2(0, 2) >= 1 and
        unquote(x) |> elem2(1, 0) |> is_integer and
        unquote(x) |> elem2(1, 0) <= 23 and
        unquote(x) |> elem2(1, 0) >= 0 and
        unquote(x) |> elem2(1, 1) |> is_integer and
        unquote(x) |> elem2(1, 1) <= 59 and
        unquote(x) |> elem2(1, 1) >= 0 and
        unquote(x) |> elem2(1, 2) |> is_integer and
        unquote(x) |> elem2(1, 2) <= 60 and
        unquote(x) |> elem2(1, 2) >= 0
    end
  end

  @doc """
  This function converts Erlang timestamp tuples into DateTimes.
  """
  def to_ics(timestamp) when is_datetime_tuple(timestamp) do
    timestamp
    |> Timex.to_datetime()
    |> Value.to_ics()
  end

  def to_ics(x), do: x
end

defimpl Value, for: DateTime do
  use Timex

  @doc """
  This function converts DateTimes to UTC timezone and then into Strings in the
  iCal format
  """
  def to_ics(%DateTime{} = timestamp) do
    format_string = "{YYYY}{0M}{0D}T{h24}{m}{s}"

    {:ok, result} =
      timestamp
      |> Timex.format(format_string)

    result
  end
end

defimpl Value, for: Date do
  use Timex

  @doc """
  This function converts DateTimes to UTC timezone and then into Strings in the
  iCal format
  """
  def to_ics(%Date{} = timestamp) do
    format_string = "{YYYY}{0M}{0D}"

    {:ok, result} =
      timestamp
      |> Timex.format(format_string)

    result
  end
end

defimpl Value, for: Any do
  def to_ics(x), do: x
end
