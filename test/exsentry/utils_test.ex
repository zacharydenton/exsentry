defmodule ExSentry.Utils do
  use ExSpec, async: true

  doctest ExSentry.Utils

  describe "version" do
    it "returns the correct version string" do
      assert(Regex.match?(~r"^\d+\.\d+\.\d+", ExSentry.Utils.version))
    end
  end
end

