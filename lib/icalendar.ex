defmodule ICalendar do
  @moduledoc """
  Generating ICalendars
  """

  defstruct events: []
  defdelegate to_ics(events), to: ICalendar.Serialize
  defdelegate from_ics(events), to: ICalendar.Deserialize

  @doc """
  To create a Phoenix/Plug controller and view that output ics format:
  Add to your config.exs:
  ```
  config :phoenix, :format_encoders,
    ics: ICalendar
  ```
  In your controller use:
  `
    calendar = %ICalendar{ events: events }
    render(conn, "index.ics", calendar: calendar)
  `
  The important part here is `.ics`. This triggers the `format_encoder`.

  In your view can put:
  ```
  def render("index.ics", %{calendar: calendar}) do
    calendar
  end
  ```
  """
  def encode_to_iodata(calendar, options \\ []) do
    {:ok, encode_to_iodata!(calendar, options)}
  end
  def encode_to_iodata!(calendar, _options \\ []) do
    to_ics(calendar)
  end
end

defimpl ICalendar.Serialize, for: ICalendar do
  def to_ics(calendar) do
  events = Enum.map( calendar.events, &ICalendar.Serialize.to_ics/1 )
  """
  BEGIN:VCALENDAR
  CALSCALE:GREGORIAN
  VERSION:2.0
  #{events}END:VCALENDAR
  """
  end
end
