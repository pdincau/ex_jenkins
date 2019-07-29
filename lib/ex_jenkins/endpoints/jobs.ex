defmodule ExJenkins.Jobs do
  @moduledoc """
  This module provides functionalities to handle Jenkins Folders Jobs.
  """

  use HTTPoison.Base

  alias HTTPoison.{Response, Error}
  alias ExJenkins.Headers

  @doc """
    Start a standard or parameterized jenkins job

    ## Examples

        iex> ExJenkins.Jobs.start("myjob")
        {:ok, {:started, location}}

        iex> ExJenkins.Jobs.start("myjob", params: [foo: "bar", foo2: "bar2"])
        {:ok, {:started, location}}

        ## You can also override token
        iex> ExJenkins.Jobs.start("myjob", params: [foo: "bar", foo2: "bar2"], token: "anothertoken")
        {:ok, {:started, location}}
  """
  def start(job, opts \\ []) do
    token = Keyword.get(opts, :token, ExJenkins.token())
    params = Keyword.get(opts, :params, [])

    response =
      case params do
        [] ->
          post("job/" <> job <> "/build?token=" <> token, "")

        params ->
          post("job/" <> job <> "/buildWithParameters?token=" <> token, {:form, params})
      end

    response |> handle_start_job_response
  end

  @doc """
    Stop a Jenkins job.

    ## Examples

        iex> ExJenkins.Jobs.stop("myjob")
        {:ok, {:stopped, location}}
  """
  def stop(job, opts \\ []) do
    number = Keyword.get(opts, :number, "lastBuild")

    post("job/" <> job <> "/" <> adapt_number(number) <> "/stop", "")
    |> handle_stop_job_response
  end

  @doc """
    Retrieve the status of a build for a given Jenkins job.

    ## Examples

        iex> ExJenkins.Jobs.status("myjob", 3)
        {:ok, {{:number, 3}, {:status, "SUCCESS"}}}
  """
  def status(job, opts \\ []) do
    number = Keyword.get(opts, :number, "lastBuild")

    get("job/" <> job <> "/" <> adapt_number(number) <> "/api/json")
    |> handle_status_job_response
  end

  @doc """
    Retrieves the log of a Jenkins job.

    ## Examples

        iex> ExJenkins.Jobs.log("myjob")
        {:ok, {:log, "your Jenkins job log"}}
  """
  def log(job, opts \\ []) do
    number = Keyword.get(opts, :number, "lastBuild")

    get("job/" <> job <> "/" <> adapt_number(number) <> "/consoleText")
    |> handle_log_job_response
  end

  @doc """
    Enable a disabled Jenkins job.

    ## Examples

        iex> ExJenkins.Jobs.enable("myjob")
        {:ok, :enabled}
  """
  def enable(job) do
    post("job/" <> job <> "/enable", "")
    |> handle_enable_disable_job_response(:enabled)
  end

  @doc """
    Disable Jenkins job.

    ## Examples

        iex> ExJenkins.Jobs.disable("myjob")
        {:ok, :disabled}
  """
  def disable(job) do
    post("job/" <> job <> "/disable", "")
    |> handle_enable_disable_job_response(:disabled)
  end

  @doc """
    Delete Jenkins job.

    ## Examples

        iex> ExJenkins.Jobs.delete("myjob")
        {:ok, :deleted}
  """
  def delete(job) do
    post("job/" <> job <> "/doDelete", "")
    |> handle_delete_job_response
  end

  @doc """
    Creates a new Jenkins job copying it from another.

    ## Examples

        iex> ExJenkins.Jobs.copy("myjob", "myotherjob")
        {:ok, {:log, "your Jenkins job log"}}
  """
  def copy(from_job, to_job) do
    post("createItem?name=" <> to_job <> "&mode=copy&from=" <> from_job, "")
    |> handle_copy_job_response
  end

  @doc """
    Retrieves the configuration file of a Jenkins job.

    ## Examples

        iex> ExJenkins.Jobs.config_file("myjob")
        {:ok, {:config_file, "your Jenkins job log"}}
  """
  def config_file(job) do
    get("job/" <> job <> "/config.xml")
    |> handle_config_file_job_response
  end

  @doc """
    Creates a Jenkins job using a given configuration file.

    ## Examples

        iex> ExJenkins.Jobs.create("myjob", "xml configuration file")
        {:ok, :created}
  """
  def create(job, config_file) do
    request(:post, "createItem?name=" <> job, config_file, [{"Content-Type", "text/xml"}], [])
    |> handle_create_job_response
  end

  @doc """
    Creates a Jenkins job in a folder using a given configuration file.

    ## Examples

        iex> ExJenkins.Jobs.create("myjob", "folder", "xml configuration file")
        {:ok, :created}
  """
  def create(job, folder, config_file) do
    request(
      :post,
      "job/" <> folder <> "/createItem?name=" <> job,
      config_file,
      [{"Content-Type", "text/xml"}],
      []
    )
    |> handle_create_job_response
  end

  @doc """
    Updates a Jenkins job using a given configuration file.

    ## Examples

        iex> ExJenkins.Jobs.update("myjob", "xml configuration file")
        {:ok, :updated}
  """
  def update(job, config_file) do
    request(
      :post,
      "job/" <> job <> "/config.xml",
      config_file,
      [{"Content-Type", "text/xml"}],
      []
    )
    |> handle_update_job_response
  end

  @doc """
    Retrieves all Jenkins jobs.

    ## Examples

        iex> ExJenkins.Jobs.all
        {:ok, ["job1", "job2", "jobN"]}
  """
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
        json_body = body |> Poison.decode!()
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
        {:ok, :updated}

      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_all_job_response(response) do
    case response do
      {:ok, %Response{status_code: 200, body: body}} ->
        json_body = body |> Poison.decode!()
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

      {:ok, %Response{status_code: status_code}} ->
        {:error, status_code}

      {:error, %Error{reason: _reason}} ->
        {:error, :generic_error}
    end
  end

  defp parse_jobs([]), do: []

  defp parse_jobs([job | other_jobs]) do
    [job["name"] | parse_jobs(other_jobs)]
  end

  defp process_request_headers(headers) do
    headers
    |> Headers.add_authorization_header()
    |> Headers.add_crumb_header()
  end

  defp process_url(endpoint) do
    ExJenkins.base_url() <> endpoint
  end

  defp adapt_number(number) when is_integer(number) do
    Integer.to_string(number)
  end

  defp adapt_number("lastBuild") do
    "lastBuild"
  end
end
