defmodule ExSentry.PlugTest do
  use ExSpec, async: true
  doctest ExSentry.Plug

  describe "handle_errors" do
    it "returns :ok just like capture_exception" do
      try do
        raise "omglol"
      rescue
        e ->
          st = System.stacktrace
          assert(:ok == ExSentry.Plug.handle_errors(FakeConn.conn, %{reason: e, stack: st}))
      end
    end
  end
end

