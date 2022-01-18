defmodule ExJenkins.HeadersTest do
  use ExUnit.Case

  describe "extract/2" do
    test "not case sensitive lower to upper" do
      headers = [{"header0", 0}, {"header1", 1}]
      name = "HEADER0"
      assert {"header0",0} == ExJenkins.Headers.extract(headers,name)
    end

    test "not case sensitive upper to lower" do
      headers = [{"HEADER0", 0}, {"HEADER1", 1}]
      name = "header0"
      assert {"HEADER0",0} == ExJenkins.Headers.extract(headers,name)
    end

    test "header not found" do
      headers = [{"HEADER0", 0}, {"HEADER1", 1}]
      name = "header3"
      assert nil == ExJenkins.Headers.extract(headers,name)
    end

    test "header found and previous ones ignored" do
      headers = [{"header0", 0}, {"header1", 1}, {"header2", 2}, {"header3", 3}]
      name = "header3"
      assert {"header3", 3} == ExJenkins.Headers.extract(headers,name)
    end

  end
end
