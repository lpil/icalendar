defprotocol ICalendar.Deserialize do
  def from_ics(ics)
end

alias ICalendar.Deserialize

defimpl ICalendar.Deserialize, for: BitString do
  alias ICalendar.Util.Deserialize

  def from_ics(ics) do
    ics
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing/1)
    |> Deserialize.build_event()
  end
end
