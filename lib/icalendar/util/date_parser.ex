defmodule ICalendar.Util.DateParser do
  @moduledoc """
  Responsible for parsing datestrings in predefined formats with `parse/1` and
  `parse/2`.

  Credit to @fazibear for this module
  """

  @doc """
  Responsible for parsing datestrings in predefined formats into %DateTime{}
  structs. Valid formats are defined by the "Internet Calendaring and Scheduling
  Core Object Specification" (RFC 2445).
    - **Full text:**      http://www.ietf.org/rfc/rfc2445.txt
    - **DateTime spec:**  http://www.kanzaki.com/docs/ical/dateTime.html
    - **Date spec:**      http://www.kanzaki.com/docs/ical/date.html
  ## Valid Formats
  The format is based on the [ISO 8601] complete representation, basic format
  for a calendar date and time of day. The text format is a concatenation of
  the "date", followed by the LATIN CAPITAL LETTER T character (US-ASCII
  decimal 84) time designator, followed by the "time" format.
    1. **<YYYYMMDD>T<HHMMSS>** -
       The date with local time form is simply a date-time value that does not
       contain the UTC designator nor does it reference a time zone. For
       example, the following represents Janurary 18, 1998, at 11 PM:
           19980118T230000
    2. **<YYYYMMDD>T<HHMMSS>Z** -
       The date with UTC time, or absolute time, is identified by a LATIN
       CAPITAL LETTER Z suffix character (US-ASCII decimal 90), the UTC
       designator, appended to the time value. For example, the following
       represents January 19, 1998, at 0700 UTC:
           19980119T070000Z
  The format for the date value type is expressed as the [ISO 8601] complete
  representation, basic format for a calendar date. The textual format
  specifies a four-digit year, two-digit month, and two-digit day of the
  month. There are no separator characters between the year, month and day
  component text.
    3. **<YYYYMMDD>** -
      The following represents July 14, 1997:
            19970714
    4. **<YYYYMMDD>Z** -
       A basic date in absolute time. The following represents July 14, 1997 UTC:
            19970714Z
  ## Resulting Timezone
    If the datestring has a Zulu time indicator (ending in "Z"), then the
    returned %DateTime{} will be in UTC, regardless of the inputted tzid.
    If the tzid is a valid tzid (ex. "America/New_York"), `parse/2` will return
    a %DateTime{} with the given timezone.
    Otherwise, if `parse/1` is used or `parse/2` is used with a `nil` tzid,
    the returned %DateTime{} will be in the local timezone.
  """

  @type valid_timezone :: String.t | :utc | :local

  @spec parse(String.t, valid_timezone | nil) :: %DateTime{}
  def parse(data, tzid \\ nil)

  # Date Format: "19690620T201804Z", Timezone: *
  def parse(<< year :: binary-size(4), month :: binary-size(2), day :: binary-size(2), "T",
               hour :: binary-size(2), minutes :: binary-size(2), seconds :: binary-size(2), "Z" >>,
               _timezone) do
    date = {year, month, day}
    time = {hour, minutes, seconds}

    {to_integers(date), to_integers(time)}
    |> NaiveDateTime.from_erl!()
    |> DateTime.from_naive!("Etc/UTC")
  end

  # Date Format: "19690620T201804", Timezone: nil
  def parse(<< year :: binary-size(4), month :: binary-size(2), day :: binary-size(2), "T",
               hour :: binary-size(2), minutes :: binary-size(2), seconds :: binary-size(2) >>,
               nil) do
    date = {year, month, day}
    time = {hour, minutes, seconds}

    {to_integers(date), to_integers(time)}
    |> NaiveDateTime.from_erl!()
    |> DateTime.from_naive!("Etc/UTC")
  end

  # Date Format: "19690620T201804", Timezone: *
  def parse(<< year :: binary-size(4), month :: binary-size(2), day :: binary-size(2), "T",
               hour :: binary-size(2), minutes :: binary-size(2), seconds :: binary-size(2) >>,
               timezone) do
    date = {year, month, day}
    time = {hour, minutes, seconds}

    {to_integers(date), to_integers(time)}
    |> Timex.to_datetime(timezone)
  end

  # Date Format: "19690620Z", Timezone: *
  def parse(<< year :: binary-size(4), month :: binary-size(2), day :: binary-size(2), "Z" >>, _timezone) do
    {to_integers({year, month, day}), {0, 0, 0}}
    |> Timex.to_datetime()
  end

  # Date Format: "19690620", Timezone: *
  def parse(<< year :: binary-size(4), month :: binary-size(2), day :: binary-size(2) >>, _timezone) do
    {to_integers({year, month, day}), {0, 0, 0}}
    |> Timex.to_datetime()
  end

  @spec to_integers({String.t, String.t, String.t}) :: {integer, integer, integer}
  defp to_integers({str1, str2, str3}) do
    {
      String.to_integer(str1),
      String.to_integer(str2),
      String.to_integer(str3)
    }
  end
end
