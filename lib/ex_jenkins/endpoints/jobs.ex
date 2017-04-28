defmodule ExJenkins.Jobs do

  use HTTPoison.Base

  alias HTTPoison.{Response, Error}
  alias ExJenkins.Headers

  def start(job, token \\ ExJenkins.token) do
    post("job/" <> job <> "/build?token=" <> token, "")
    |> handle_start_job_response
  end

  def stop(job, number \\ "lastBuild") do
    post("job/" <> job <> "/" <> adapt_number(number) <> "/stop", "")
    |> handle_stop_job_response
  end

  def status(job, number \\ "lastBuild") do
    get("job/" <> job <> "/" <> adapt_number(number) <> "/api/json")
    |> handle_status_job_response
  end

  def log(job, number \\ "lastBuild") do
    get("job/" <> job <> "/" <> adapt_number(number) <> "/consoleText")
    |> handle_log_job_response
  end

  def enable(job) do
    post("job/" <> job <> "/enable", "")
    |> handle_enable_disable_job_response(:enabled)
  end

  def disable(job) do
    post("job/" <> job <> "/disable", "")
    |> handle_enable_disable_job_response(:disabled)
  end

  def delete(job) do
    post("job/" <> job <> "/doDelete", "")
    |> handle_delete_job_response
  end

  def copy(from_job, to_job) do
    post("createItem?name=" <> to_job <> "&mode=copy&from=" <> from_job, "")
    |> handle_copy_job_response
  end

  def config_file(job) do
    get("job/" <> job <> "/config.xml")
    |> handle_config_file_job_response
  end

  def create(job, config_file) do
    request(:post, "createItem?name=" <> job, config_file, [{"Content-Type", "text/xml"}], [])
    |> handle_create_job_response
  end

  def create(job, folder, config_file) do
    request(:post, "job/" <> folder <> "/createItem?name=" <> job, config_file, [{"Content-Type", "text/xml"}], [])
    |> handle_create_job_response
  end

  def update(job, config_file) do
    request(:post, "job/" <> job <> "/config.xml", config_file, [{"Content-Type", "text/xml"}], [])
    |> handle_update_job_response
  end

  def all do
    get("api/json?tree=jobs[name]")
    |> handle_all_job_response
  end

  defp handle_start_job_response(response) do
    case response do
      {:ok, %Response{status_code: 201, headers: headers}} ->
        {"Location", location} = Headers.extract(headers, "Location")
        {:ok, {:started, location}}
      {:ok, %Response{status_code: 409}} ->
        {:error, :disabled}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_stop_job_response(response) do
    case response do
      {:ok, %Response{status_code: 302, headers: headers}} ->
        {"Location", location} = Headers.extract(headers, "Location")
        {:ok, {:stopped, location}}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_status_job_response(response) do
    case response do
      {:ok, %Response{status_code: 200, body: body}} ->
        json_body = body |> Poison.decode!
        {:ok, {{:number, json_body["number"]}, {:status, json_body["result"]}}}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_log_job_response(response) do
    case response do
      {:ok, %Response{status_code: 200, body: body}} ->
        {:ok, {:log, body}}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_enable_disable_job_response(response, toggle) do
    case response do
      {:ok, %Response{status_code: 302}} ->
        {:ok, toggle}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_delete_job_response(response) do
    case response do
      {:ok, %Response{status_code: 302}} ->
        {:ok, :deleted}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_copy_job_response(response) do
    case response do
      {:ok, %Response{status_code: 302}} ->
        {:ok, :created}
      {:ok, %Response{status_code: 400}} ->
        {:error, :cannot_copy}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_config_file_job_response(response) do
    case response do
      {:ok, %Response{status_code: 200, body: body}} ->
        {:ok, {:config_file, body}}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_create_job_response(response) do
    case response do
      {:ok, %Response{status_code: 200}} ->
        {:ok, :created}
      {:ok, %Response{status_code: 400}} ->
        {:error, :cannot_create}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_update_job_response(response) do
    case response do
      {:ok, %Response{status_code: 200}} ->
        {:ok, :created}
      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_all_job_response(response) do
    case response do
      {:ok, %Response{status_code: 200, body: body}} ->
        json_body = body |> Poison.decode!
        jobs = parse_jobs(json_body["jobs"])
        {:ok, jobs}
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

  defp parse_jobs([]), do: []

  defp parse_jobs([job|other_jobs]) do
    [job["name"]|parse_jobs(other_jobs)]
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

  defp adapt_number("lastBuild") do
    "lastBuild"
  end

end
