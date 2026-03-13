defmodule ICalendar.Event do
  @moduledoc """
  Calendars have events.
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
            attendees: []

  @typedoc """
  An Event struct

  * `summary`: The summary of the event
  * `dtstart`: The start time of the event
  * `dtend`: The end time of the event
  * `rrule`: The recurrence rule
  * `exdates`: The exception dates
  * `description`: The description of the event
  * `location`: The location of the event
  * `url`: The URL of the event
  * `uid`: The unique identifier of the event
  * `prodid`: The product identifier of the event
  * `status`: The status of the event
  * `categories`: The categories of the event
  * `class`: The class of the event
  * `comment`: An optional comment
  * `geo`: The latitude and longitude of the event
  * `modified`: The last modified time of the event
  * `organizer`: The organizer of the event
  * `sequence`: The sequence number of the event
  * `attendees`: The attendees of the event
  """
  @type t :: %__MODULE__{
          summary: String.t(),
          dtstart: DateTime.t(),
          dtend: DateTime.t(),
          rrule: map(),
          exdates: [DateTime.t()],
          description: String.t(),
          location: String.t(),
          url: String.t(),
          uid: String.t() | integer(),
          prodid: String.t(),
          status: String.t(),
          categories: [String.t()],
          class: String.t(),
          comment: String.t(),
          geo: {float(), float()},
          modified: DateTime.t(),
          organizer: String.t(),
          sequence: integer(),
          attendees: [map()]
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
