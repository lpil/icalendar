defmodule ICalendar.ValueTest do
  use ExUnit.Case

  alias ICalendar.Value

  test "value of a datetime" do
    result = Value.to_ics(Timex.to_datetime({{2016, 1, 4}, {0, 42, 23}}))
    assert result == "20160104T004223"
  end

  test "value of a datetime tuple" do
    result = Value.to_ics({{2016, 1, 4}, {0, 42, 23}})
    assert result == "20160104T004223"
  end

  test "value of a nearly datetime tuple" do
    result = Value.to_ics({{2016, 13, 4}, {0, 42, 23}})
    assert result == {{2016, 13, 4}, {0, 42, 23}}
  end

  test "value of a very different tupe" do
    result = Value.to_ics({:ok, "Hi there"})
    assert result == {:ok, "Hi there"}
  end

  test "value of a string with newline" do
    result = Value.to_ics """
    Hello
    World!
    """
    assert result == ~S"Hello\nWorld!\n"
  end

  test "value of a string with newline like chars" do
    result = Value.to_ics ~S"Hi\nthere"
    assert result == ~S"Hi\\nthere"
  end

  test "value of an RRULE" do
    rrule = %ICalendar.RRULE{
      frequency: :yearly,
      until: Timex.to_datetime({{2022, 10, 12}, {15, 30, 0}}, "Etc/UTC"),
      by_second: [1, 3, 5],
      by_minute: [1, 3, 5],
      by_hour: [12, 13, 14],
      by_month_day: [2, 4, 6],
      by_year_day: [50, 75, 150],
      by_week_number: [25, 35, 45],
      by_set_pos: -5,
      by_day: [:monday, :wednesday, :friday],
      by_month: [:april, :june],
      week_start: :monday
    }
    result = Value.to_ics(rrule)
    assert result == [
      "BYDAY=MO,WE,FR",
      "BYHOUR=12,13,14",
      "BYMINUTE=1,3,5",
      "BYMONTH=4,6",
      "BYMONTHDAY=2,4,6",
      "BYSECOND=1,3,5",
      "BYWEEKNO=25,35,45",
      "BYYEARDAY=50,75,150",
      "FREQ=YEARLY",
      "UNTIL=20221012T153000",
      "WKST=MO"
    ] |> Enum.join(";")
  end
end
