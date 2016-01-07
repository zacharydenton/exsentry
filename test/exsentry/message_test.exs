defmodule ExSentry.MessageTest do
  use ExSpec, async: true

  doctest ExSentry.Message

  describe "get_auth_header_value" do
    it "returns a well-formatted string header" do
      args = %{
        version: "1.2.3",
        key: "omgkey",
        secret: "omgsecret",
        timestamp: 1234567890
      }
      assert(ExSentry.Message.get_auth_header_value(args) ==
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
                          ExSentry.Message.get_auth_header_value(args)))
    end
  end

  @stacktrace [
    {:erl_internal, :op_type, [:get_stacktrace, 0], [file: 'erl_internal.erl', line: 212]},
    {:elixir_translator, :guard_op, 2, [file: 'src/elixir_translator.erl', line: 309]},
    {:elixir_translator, :translate, 2, []},
    {:elixir_translator, :translate_arg, 3, [file: 'src/elixir_translator.erl', line: 349]},
    {:lists, :mapfoldl, 3, [line: 1353]},
    {:elixir_translator, :translate, 2, [file: 'src/elixir_translator.erl', line: 263]},
    {:elixir, :quoted_to_erl, 3, [file: 'src/elixir.erl', line: 228]},
    {:elixir, :eval_forms, 4, [file: 'src/elixir.erl']}
  ]

  @fst [
    %{filename: 'src/elixir.erl', function: "eval_forms/4", module: :elixir},
    %{filename: 'src/elixir.erl', function: "quoted_to_erl/3", lineno: 228, module: :elixir},
    %{filename: 'src/elixir_translator.erl', function: "translate/2", lineno: 263, module: :elixir_translator},
    %{function: "mapfoldl/3", lineno: 1353, module: :lists},
    %{filename: 'src/elixir_translator.erl', function: "translate_arg/3", lineno: 349, module: :elixir_translator},
    %{module: :elixir_translator, function: "translate/2"},
    %{filename: 'src/elixir_translator.erl', function: "guard_op/2", lineno: 309, module: :elixir_translator},
    %{filename: 'erl_internal.erl', function: "op_type/2", lineno: 212, module: :erl_internal}
  ]

  describe "format_stacktrace" do
    it "formats stacktrace correctly" do
      fst = ExSentry.Message.format_stacktrace(@stacktrace)
      assert(@fst == fst)
    end
  end
end

