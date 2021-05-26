# ICalendar

[![Test](https://github.com/lpil/icalendar/actions/workflows/test.yml/badge.svg)](https://github.com/lpil/icalendar/actions/workflows/test.yml)
[![Module Version](https://img.shields.io/hexpm/v/icalendar.svg)](https://hex.pm/packages/icalendar)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/icalendar/)
[![Total Download](https://img.shields.io/hexpm/dt/icalendar.svg)](https://hex.pm/packages/icalendar)
[![License](https://img.shields.io/hexpm/l/icalendar.svg)](https://github.com/lpil/icalendar/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/lpil/icalendar.svg)](https://github.com/lpil/icalendar/commits/master)

A small library for reading and writing ICalendar files.

## Installation

The package can be installed by adding `:icalendar` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:icalendar, "~> 1.1.0"}
  ]
end
```

## Usage

```elixir
events = [
  %ICalendar.Event{
    summary: "Film with Amy and Adam",
    dtstart: {{2015, 12, 24}, {8, 30, 00}},
    dtend:   {{2015, 12, 24}, {8, 45, 00}},
    description: "Let's go see Star Wars.",
    location: "123 Fun Street, Toronto ON, Canada"
  },
  %ICalendar.Event{
    summary: "Morning meeting",
    dtstart: Timex.now,
    dtend:   Timex.shift(Timex.now, hours: 3),
    description: "A big long meeting with lots of details.",
    location: "456 Boring Street, Toronto ON, Canada"
  },
]
ics = %ICalendar{ events: events } |> ICalendar.to_ics
File.write!("calendar.ics", ics)

# BEGIN:VCALENDAR
# CALSCALE:GREGORIAN
# VERSION:2.0
# BEGIN:VEVENT
# DESCRIPTION:Let's go see Star Wars.
# DTEND:20151224T084500Z
# DTSTART:20151224T083000Z
# LOCATION: 123 Fun Street\, Toronto ON\, Canada
# SUMMARY:Film with Amy and Adam
# END:VEVENT
# BEGIN:VEVENT
# DESCRIPTION:A big long meeting with lots of details.
# DTEND:20151224T223000Z
# DTSTART:20151224T190000Z
# LOCATION:456 Boring Street\, Toronto ON\, Canada
# SUMMARY:Morning meeting
# END:VEVENT
# END:VCALENDAR
```

## See Also

- https://en.wikipedia.org/wiki/ICalendar
- http://www.kanzaki.com/docs/ical/dateTime.html

## Copyright and License

Copyright (c) 2015 Louis Pilfold

This library is released under the MIT License. See the [LICENSE.md](./LICENSE.md) file
for further details.
