defmodule ExJenkins.Headers do
  alias ExJenkins.CrumbServer

  def extract(headers, name) do
    downcase_name = String.downcase(name)
    Enum.find(headers, &(String.downcase(elem(&1, 0)) == downcase_name))
  end

  def add_authorization_header(headers) do
    headers
    |> enrich({"Authorization", ExJenkins.basic_auth_string()})
  end

  def add_crumb_header(headers) do
    {:ok, crumb_info} = CrumbServer.crumb_info()

    headers
    |> enrich({crumb_info.request_field, crumb_info.value})
  end

  defp enrich(headers, header) do
    Enum.concat(headers, [header])
  end
end
