defmodule ExJenkins.Jenkins do

  use HTTPoison.Base

  alias HTTPoison.{Response, Error}
  alias ExJenkins.Headers

  def quiet_down do
    post("quietDown", "")
    |> handle_quiet_down_cancel_quiet_down_response(:quieted_down)
  end

  def cancel_quiet_down do
    post("cancelQuietDown", "")
    |> handle_quiet_down_cancel_quiet_down_response(:quieted_down)
  end

  def restart(mode \\ :safe) do
    restart_endpoint(mode)
    |> post("")
    |> handle_restart_response
  end

  defp handle_restart_response(response) do
    case response do
      {:ok, %Response{status_code: 302}} ->
        {:ok, :restart_command_issued}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_quiet_down_cancel_quiet_down_response(response, toggle) do
    case response do
      {:ok, %Response{status_code: 302}} ->
        {:ok, toggle}
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

  defp restart_endpoint(:safe), do: "safeRestart"

  defp restart_endpoint(:hard), do: "restart"

  defp process_url(endpoint) do
    ExJenkins.base_url <> endpoint
  end

  defp process_request_headers(headers) do
    headers
    |> Headers.add_authorization_header()
    |> Headers.add_crumb_header()
  end

end
