defprotocol ICalendar.Deserialize do
  def from_ics(ics)
end

defimpl ICalendar.Deserialize, for: BitString do
  alias ICalendar.Event

  def from_ics(ics) do
    ics
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&retrieve_kvs/1)
    |> Enum.reduce(%Event{}, &build_event/2)
  end

  def retrieve_kvs(line) do
    [key, value] = String.split(line, ":")
    {String.upcase(key), value}
  end

  def build_event({"DESCRIPTION", description}, acc) do
    %{acc | description: description}
  end
  def build_event({"DTSTART", dtstart}, acc) do
    %{acc | dtstart: to_date(dtstart)}
  end
  def build_event({"DTEND", dtend}, acc), do: %{acc | dtend: to_date(dtend)}
  def build_event({"SUMMARY", summary}, acc), do: %{acc | summary: summary}
  def build_event(_, acc), do: acc

  def to_date(date_string) do

    [date, time] =
      date_string
      |> String.upcase
      |> String.split(["T", "Z"], trim: true)

    year =
      date
      |> String.slice(0..3)
      |> String.to_integer

    month =
      date
      |> String.slice(4..5)
      |> String.to_integer

    day =
      date
      |> String.slice(6..7)
      |> String.to_integer

    hour =
      time
      |> String.slice(0..1)
      |> String.to_integer

    minute =
      time
      |> String.slice(2..3)
      |> String.to_integer

    second =
      time
      |> String.slice(4..5)
      |> String.to_integer

    {{year, month, day}, {hour, minute, second}}
  end

end
