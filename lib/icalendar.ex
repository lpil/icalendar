defmodule ICalendar do
  @moduledoc """
  Generating ICalendars.
  """

  defstruct events: []
  defdelegate to_ics(events, options \\ []), to: ICalendar.Serialize
  defdelegate from_ics(events), to: ICalendar.Deserialize

  @doc """
  To create a Phoenix/Plug controller and view that output ics format:

  Add to your config.exs:

      config :phoenix, :format_encoders,
        ics: ICalendar

  In your controller use:

      calendar = %ICalendar{ events: events }
      render(conn, "index.ics", calendar: calendar)

  The important part here is `.ics`. This triggers the `format_encoder`.

  In your view can put:

      def render("index.ics", %{calendar: calendar}) do
        calendar
      end

  """
  def encode_to_iodata(calendar, options \\ []) do
    {:ok, encode_to_iodata!(calendar, options)}
  end

  def encode_to_iodata!(calendar, _options \\ []) do
    to_ics(calendar)
  end
end

defimpl ICalendar.Serialize, for: ICalendar do
  def to_ics(calendar, options \\ []) do
    events = Enum.map(calendar.events, &ICalendar.Serialize.to_ics/1)

    """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    #{calendar_attributes(options)}
    #{events}END:VCALENDAR
    """
  end

  defp calendar_attributes(options) do
    vendor = Keyword.get(options, :vendor, "Elixir ICalendar")
    name = Keyword.get(options, :name)
    id = Keyword.get(options, :id)

    [vendor: vendor, name: name, id: id]
    |> Enum.reject(fn {_, v} -> is_nil(v) or v == "" end)
    |> Enum.map(&attribute/1)
    |> Enum.join("\n")
  end

  defp attribute({:vendor, vendor}), do: "PRODID:-//Elixir ICalendar//#{vendor}//EN"
  defp attribute({:name, name}), do: "X-WR-CALNAME:#{name}"
  defp attribute({:id, id}), do: "X-WR-RELCALID:#{id}"
end
