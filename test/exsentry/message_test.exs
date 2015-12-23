defmodule ExSentry.MessageTest do
  use ExSpec, async: true

  doctest ExSentry.Message

  describe "get_auth_header" do
    it "returns a well-formatted string header" do
      args = %{
        version: "1.2.3",
        key: "omgkey",
        secret: "omgsecret",
        timestamp: 1234567890
      }
      assert(ExSentry.Message.get_auth_header(args) ==
               "X-Sentry-Auth: Sentry sentry_version=7, sentry_client=" <>
               "\"ExSentry/1.2.3\", sentry_timestamp=1234567890, " <>
               "sentry_key=omgkey, sentry_secret=omgsecret")
    end

    it "inserts timestamps when not provided" do
      args = %{
        version: "1.2.3",
        key: "omgkey",
        secret: "omgsecret",
      }
      assert(Regex.match?(~r"sentry_timestamp=\d{10}", ExSentry.Message.get_auth_header(args)))
    end
  end
end

