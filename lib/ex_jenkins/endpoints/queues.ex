defmodule ExJenkins.Queues do

  use HTTPoison.Base

  alias HTTPoison.{Response, Error}
  alias ExJenkins.Headers

  def info(number) do
    case get("queue/item/" <> adapt_number(number) <> "/api/json") do
      {:ok, %Response{status_code: 200, body: body}} ->
        json_body = body |> Poison.decode!
        {:ok, {:executable_number, json_body["executable"]["number"]}}
      error_response ->
        handle_error(error_response)
    end
  end

  def cancel(number) do
    case post("queue/cancelItem?id=" <> adapt_number(number), "") do
      {:ok, %Response{status_code: 302}} ->
        {:ok, :canceled}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_error(response) do
    case response do
      {:ok, %Response{status_code: 404}} ->
        {:error, :not_found}
      {:error, %Error{reason: _reason}} ->
        {:error, :generic_error}
    end
  end

  defp process_request_headers(headers) do
    headers
    |> Headers.add_authorization_header()
    |> Headers.add_crumb_header()
  end

  defp process_url(endpoint) do
    ExJenkins.base_url <> endpoint
  end

  defp adapt_number(number) when is_integer(number) do
    Integer.to_string(number)
  end

end
