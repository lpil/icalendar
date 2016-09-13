defmodule ICalendar.ValueTest do
  use ExUnit.Case

  alias ICalendar.Value

  test "value of a datetime" do
    result = Value.to_ics(Timex.to_datetime({{2016, 1, 4}, {0, 42, 23}}))
    assert result == "20160104T004223Z"
  end

  test "datetimes' timezones are all converted to UTC" do
    time = Timex.to_datetime({{2016, 1, 1}, {3, 2, 1}}, "America/Chicago")
    assert Value.to_ics(time) == "20160101T090201Z"
  end

  test "value of a datetime tuple" do
    result = Value.to_ics({{2016, 1, 4}, {0, 42, 23}})
    assert result == "20160104T004223Z"
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
end
