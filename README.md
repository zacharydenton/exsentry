# ExSentry

An Elixir library for sending exception events to
[Sentry](https://getsentry.com).

Not an officially supported Sentry client.

Alpha quality, do not use, YMMV, etc.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add exsentry to your list of dependencies in `mix.exs`:

        def deps do
          [{:exsentry, "~> 0.0.1"}]
        end

  2. Ensure exsentry is started before your application:

        def application do
          [applications: [:exsentry]]
        end


## Authorship and License

ExSentry is copyright 2015-2016 Appcues.

ExSentry is released under the MIT License, available at LICENSE.txt.

