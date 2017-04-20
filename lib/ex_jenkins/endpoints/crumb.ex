defmodule ExJenkins.Crumb do

  use HTTPoison.Base

  alias HTTPoison.{Response, Error}
  alias ExJenkins.Headers

  def issue do
    case get("crumbIssuer/api/json") do
      {:ok, %Response{status_code: 200, body: body}} ->
        json_body = body |> Poison.decode!
        value = json_body["crumb"]
        request_field = json_body["crumbRequestField"]
        {:ok, {{:value, value}, {:request_field, request_field}}}
      {:error, %Error{reason: _reason}} ->
        {:error, :generic_error}
    end
  end

  defp process_url(endpoint) do
    ExJenkins.base_url <> endpoint
  end

  defp process_request_headers(headers) do
    headers
    |> Headers.add_authorization_header()
  end

end
