defmodule ExSentry.Model.MessageTest do
  use ExSpec, async: true
  doctest ExSentry.Model.Message

  describe "get_auth_header_value" do
    it "returns a well-formatted string header" do
      args = %{
        version: "1.2.3",
        key: "omgkey",
        secret: "omgsecret",
        timestamp: 1234567890
      }
      assert(ExSentry.Model.Message.get_auth_header_value(args) ==
               "Sentry sentry_version=7, sentry_client=" <>
               "\"ExSentry/1.2.3\", sentry_timestamp=1234567890, " <>
               "sentry_key=omgkey, sentry_secret=omgsecret")
    end

    it "inserts timestamps when not provided" do
      args = %{
        version: "1.2.3",
        key: "omgkey",
        secret: "omgsecret",
      }
      assert(Regex.match?(~r"sentry_timestamp=\d{10}",
                          ExSentry.Model.Message.get_auth_header_value(args)))
    end
  end

  describe "serialization" do
    it "serializes to JSON" do
      opts = [message: "hi mom"]
      assert({:ok, _} = opts |> ExSentry.Model.Message.from_opts |> Poison.encode)
    end
  end

end

