defmodule ExJenkins.Queues do
  @moduledoc """
    This module provides functionalities to handle Jenkins queues.
  """

  use HTTPoison.Base

  alias HTTPoison.{Response, Error}
  alias ExJenkins.Headers

  @doc """
    Retrieve information about an item in Jenkins queue.

    ## Examples

        iex> ExJenkins.Queues.info(1)
        {:ok, {:executable_number, "2"}}
  """
  def info(number) do
    case get("queue/item/" <> adapt_number(number) <> "/api/json") do
      {:ok, %Response{status_code: 200, body: body}} ->
        json_body = body |> Poison.decode!()
        {:ok, {:executable_number, json_body["executable"]["number"]}}

      error_response ->
        handle_error(error_response)
    end
  end

  @doc """
    Cancel an item in Jenkins queue.

    ## Examples

        iex> ExJenkins.Queues.cancel(1)
        {:ok, :canceled}
  """
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

      {:ok, %Response{status_code: status_code}} ->
        {:error, status_code}

      {:error, %Error{reason: _reason}} ->
        {:error, :generic_error}
    end
  end

  @impl HTTPoison.Base
  def process_request_headers(headers) do
    headers
    |> Headers.add_authorization_header()
    |> Headers.add_crumb_header()
  end

  @impl HTTPoison.Base
  def process_url(endpoint) do
    ExJenkins.base_url() <> endpoint
  end

  defp adapt_number(number) when is_integer(number) do
    Integer.to_string(number)
  end
end
