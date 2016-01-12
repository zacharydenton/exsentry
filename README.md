# ExSentry

[![wercker status](https://app.wercker.com/status/e3f67da2ef0e409a62bb6bd65a50e7d7/s/master "wercker status")](https://app.wercker.com/project/bykey/e3f67da2ef0e409a62bb6bd65a50e7d7)
[![Hex.pm Version](http://img.shields.io/hexpm/v/exsentry.svg?style=flat)](https://hex.pm/packages/exsentry)
[![Coverage Status](https://coveralls.io/repos/appcues/exsentry/badge.svg?branch=&service=github)](https://coveralls.io/github/appcues/exsentry?branch=)

An Elixir client library for the [Sentry](https://getsentry.com) error
reporting platform.

[Full ExSentry documentation is available on
Hexdocs.pm.](http://hexdocs.pm/exsentry/ExSentry.html)

Not an officially supported Sentry client.

Offered without guarantee, YMMV, etc.


## Installation

1. Add exsentry to your list of dependencies in `mix.exs`:

        def deps do
          [{:exsentry, "~> 0.2.0"}]
        end

2. If using as an OTP application, ensure exsentry is started
   before your application in `mix.exs`:

        def application do
          [applications: [:exsentry]]
        end

   And configure your Sentry DSN in `config.exs`:

        config :exsentry, dsn: "your-dsn-here"


## Usage

ExSentry can be used as a standalone client, as an OTP application tied
into your app's lifecycle, or as a Plug in your webapp's plug stack (e.g.,
Phoenix router).

### Standalone

Create a client process like this:

    client = ExSentry.new("your-dsn-here")

And capture messages or exceptions like this:

    client |> ExSentry.capture_message("Hello world!")

    client |> ExSentry.capture_exception(an_exception)

    client |> ExSentry.capture_exceptions fn ->
      something_that_might_raise()
    end


### OTP Application

If you've configured `mix.exs` and `config.exs` as described in
installation step 2 above, you can invoke ExSentry without
explicitly creating a client:

    ExSentry.capture_message("Hello world!")

    ExSentry.capture_exception(an_exception)

    ExSentry.capture_exceptions fn ->
      something_that_might_raise()
    end


### Plug

ExSentry can be used as a Plug error handler, to automatically inform
Sentry of any exceptions encountered within your web application.

To use ExSentry as a Plug error handler, follow the OTP configuration
instructions, then put `use ExSentry.Plug` wherever your Plug stack is
defined, for instance in `web/router.ex` in a Phoenix application:

    defmodule MyApp.Router do
      use MyApp.Web, :router
      use ExSentry.Plug

      pipeline :browser do
      ...


## Authorship and License

ExSentry is copyright 2015-2016 Appcues, Inc.

ExSentry is released under the MIT License, available at LICENSE.txt.

