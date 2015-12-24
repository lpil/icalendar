defprotocol ICalendar.Serialize do
  def to_ics(data)
end

alias ICalendar.Serialize

defimpl Serialize, for: List do
  def to_ics(collection) do
    collection
    |> Enum.map(&Serialize.to_ics/1)
    |> Enum.join("\n")
  end
end
