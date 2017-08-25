defmodule ExJenkins.JenkinsHelper do
  def wait_for_jenkins(retries \\ 20)

  def wait_for_jenkins(0) do
    IO.puts "Giving up waiting"
    {:error, :timeout}
  end

  def wait_for_jenkins(retries) do
    action =
      case ExJenkins.Crumb.get("/") do
        {:ok, %HTTPoison.Response{status_code: 200}} -> :ready

        {:ok, %HTTPoison.Response{status_code: 503}} -> {:wait, 503}

        {:ok, %HTTPoison.Response{status_code: 401}} -> {:error, :invalid_jenkins_credentials}

        {:error, %HTTPoison.Error{reason: reason}}   -> {:wait, reason}

        {:ok, %HTTPoison.Response{status_code: code}} -> {:error, {:status_code, code}}
      end

    case action do
      :ready ->
        IO.puts "Ready"
        :ready

      {:error, reason} ->
        IO.puts "Error: reason #{inspect reason}"
        {:error, reason}

      {:wait, reason} ->
        IO.puts "Waiting: reason: #{inspect reason}... Retries left: #{retries}"
        :timer.sleep(1000)
        wait_for_jenkins(retries - 1)
    end
  end

  def start_jenkins do
    IO.write "Starting Jenkins docker container..."
    System.cmd("sh", ["-c", "./start-jenkins.sh"])
  end

  def stop_jenkins do
    IO.write "Stopping Jenkins docker container..."
    System.cmd("sh", ["-c", "./stop-jenkins.sh"])
  end
end
