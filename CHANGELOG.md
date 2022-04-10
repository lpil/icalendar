# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

- Add support for the `DTSTAMP` field.
  If not provided, it is initialized to the current UTC DateTime when serializing.

## v1.1.2 - 2022-01-16

- Handle calendars that wrap output such as Google Calendar

## v1.1.1 - 2021-12-26

- Fixed a bug where newlines were incorrectly handled.

## v1.1.0 - 2020-10-06

- The `ICalendar.Recurrence.get_recurrences` function has been added to enable
  calculation of recurring events from RRULE.

## v1.0.3 - 2020-08-19

- Calendars with empty lines in events are now parsed successfully.

## v1.0.2 - 2019-10-06

- Calendars with empty lines are now parsed successfully.

## v1.0.1 - 2019-09-17

- Empty parameter values in a VEVENT are now parsed successfully.

## v1.0.0 - 2019-09-05

- First stable release.
