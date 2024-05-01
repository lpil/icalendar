defmodule ICalendar.Event do
  @moduledoc """
  Calendars have events.

  BEGIN:VEVENT
  SUMMARY:Going fishing at the lake that happens to be in the middle of fun street.
  DESCRIPTION:Escape from the world. Stare at some water. Maybe you'll even catch some fish!
  LOCATION:123 Fun Street, Toronto ON, Canada
  STATUS:TENTATIVE
  CATEGORIES:Fishing,Nature
  CLASS:PRIVATE
  GEO:43.6978819;-79.3810277
  DTSTART:20151224T083000Z
  DTEND:20151224T084500Z
  RRULE:FREQ=YEARLY;UNTIL=20190217T020000Z;BYMONTH=2;BYDAY=3SU
  EXDATE:20151224T084500Z
  URL:http://www.example.com
  UID:005C73EB77840DFFB0F20D4C73A9447A
  PRODID:-//Elixir ICalendar//EN
  LAST-MODIFIED:20151224T083000Z
  SEQUENCE:0
  TZID:America/Toronto
  DTSTAMP:20151224T083000Z
  TRANSP:OPAQUE
  ATTENDEE;CN="John Doe";CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;RSVP=TRUE:mailto:5d9Hk@example.com
  ATTENDEE;CN="Jane Doe";CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;RSVP=TRUE:mailto:Jn2zK@example.com
  END:VEVENT
  """

  defstruct summary: nil,
            dtstart: nil,
            dtend: nil,
            rrule: nil,
            exdates: [],
            description: nil,
            location: nil,
            url: nil,
            uid: nil,
            prodid: nil,
            status: nil,
            categories: nil,
            class: nil,
            comment: nil,
            geo: nil,
            modified: nil,
            organizer: nil,
            sequence: nil,
            attendees: [],
            attachments: [],
            tzid: nil,
            dtstamp: nil,
            last_modified: nil,
            transp: nil

  @type t :: %__MODULE__{
          summary: String.t(),
          dtstart: DateTime.t(),
          dtend: DateTime.t(),
          rrule: map(),
          exdates: list(DateTime.t()),
          description: String.t(),
          location: String.t(),
          url: String.t(),
          uid: String.t(),
          prodid: String.t(),
          status: String.t(),
          categories: list(String.t()),
          class: String.t(),
          comment: String.t(),
          geo: {float(), float()},
          modified: DateTime.t(),
          organizer: String.t(),
          sequence: String.t(),
          attendees: list(map()),
          attachments: list(map()),
          tzid: String.t(),
          dtstamp: DateTime.t(),
          last_modified: DateTime.t(),
          transp: String.t()
        }
end

defimpl ICalendar.Serialize, for: ICalendar.Event do
  alias ICalendar.Util.KV

  def to_ics(event, _options \\ []) do
    contents = to_kvs(event)

    """
    BEGIN:VEVENT
    #{contents}END:VEVENT
    """
  end

  defp to_kvs(event) do
    event
    |> Map.from_struct()
    |> Enum.map(&to_kv/1)
    |> List.flatten()
    |> Enum.sort()
    |> Enum.join()
  end

  defp to_kv({:exdates, value}) when is_list(value) do
    case value do
      [] ->
        ""

      exdates ->
        exdates
        |> Enum.map(&KV.build("EXDATE", &1))
    end
  end

  defp to_kv({key, value}) do
    name = key |> to_string |> String.upcase()
    KV.build(name, value)
  end
end
