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

defimpl Value, for: DateTime do
  use Timex

  def to_ics(%DateTime{} = timestamp) do
    format_string = "{YYYY}{0M}{0D}T{h24}{m}{s}Z"
    {:ok, result} = timestamp |> Timex.format(format_string)
    result
  end
end

defimpl Value, for: Any do
  def to_ics(x), do: x
end
