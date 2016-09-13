defprotocol ICalendar.Deserialize do
  def from_ics(ics)
end

defimpl ICalendar.Deserialize, for: BitString do
  alias ICalendar.Event

  def from_ics(ics) do
    ics
    |> String.trim # Remove trailing whitespace
    |> String.split("\n") # Split by line
    |> Enum.map(&retrieve_kvs/1) # Convert each line into a key-value tuple
    |> Enum.reduce(%Event{}, &build_event/2) # Convert the tuple into a map
  end

  def retrieve_kvs(line) do
    [key, value] = String.split(line, ":")
    {String.upcase(key), value}
  end

  def build_event({"DESCRIPTION", description}, acc), do: Map.put(acc, :description, description)
  def build_event({"SUMMARY", summary}, acc), do: Map.put(acc, :summary, summary)
  def build_event({"DTSTART", dtstart}, acc), do: Map.put(acc, :dtstart, to_date(dtstart))
  def build_event({"DTEND", dtend}, acc), do: Map.put(acc, :dtend, to_date(dtend))
  def build_event(_, acc), do: acc

  def to_date(date_string) do

    [date, time] =
      date_string
      |> String.upcase
      |> String.split(["T", "Z"], trim: true)

    year  = String.slice(date, 0..3) |> String.to_integer
    month = String.slice(date, 4..5) |> String.to_integer
    day   = String.slice(date, 6..7) |> String.to_integer

    hour   = String.slice(time, 0..1) |> String.to_integer
    minute = String.slice(time, 2..3) |> String.to_integer
    second = String.slice(time, 4..5) |> String.to_integer

    {{year, month, day}, {hour, minute, second}}
  end

end
