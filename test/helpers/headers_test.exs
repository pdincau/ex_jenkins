defmodule ExJenkins.HeadersTest do
  use ExUnit.Case

  describe "extract/2" do
    test "extract is not case sensitive" do
      headers = [{"header0", 0}, {"header1", 1}]
      name = "HEADER0"
      assert {"header0",0} == ExJenkins.Headers.extract(headers,name)
    end
  end
end
