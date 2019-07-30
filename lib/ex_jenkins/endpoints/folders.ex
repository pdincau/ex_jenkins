defmodule ExJenkins.Folders do
  @moduledoc """
  This module provides functionalities to handle Jenkins Folders (you need Jenkins Folder Plugin).
  """

  use HTTPoison.Base

  alias HTTPoison.{Response, Error}
  alias ExJenkins.Headers

  @doc """
    Create a given `folder`.

    ## Examples

        iex> ExJenkins.Folders.create("myfolder")
        {:ok, :created}
  """
  def create(folder) do
    request(
      :post,
      "createItem?name=" <> folder <> rest_of_url(),
      "",
      [{"Content-Type", "application/x-www-form-urlencoded"}],
      []
    )
    |> handle_create_folder_response
  end

  @doc """
    Delete a given `folder`.

    ## Examples

        iex> ExJenkins.Folders.delete("myfolder")
        {:ok, :deleted}
  """
  def delete(folder) do
    post("job/" <> folder <> "/doDelete", "")
    |> handle_delete_folder_response
  end

  defp handle_create_folder_response(response) do
    case response do
      {:ok, %Response{status_code: 302}} ->
        {:ok, :created}

      {:ok, %Response{status_code: 400}} ->
        {:error, :cannot_create}

      error_response ->
        handle_error(error_response)
    end
  end

  defp handle_delete_folder_response(response) do
    case response do
      {:ok, %Response{status_code: 302}} ->
        {:ok, :deleted}

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

  defp process_request_headers(headers) do
    headers
    |> Headers.add_authorization_header()
    |> Headers.add_crumb_header()
  end

  defp process_url(endpoint) do
    ExJenkins.base_url() <> endpoint
  end

  defp rest_of_url do
    "&mode=com.cloudbees.hudson.plugins.folder.Folder&from=&json=%7B%22name%22%3A%22FolderName%22%2C%22mode%22%3A%22com.cloudbees.hudson.plugins.folder.Folder%22%2C%22from%22%3A%22%22%2C%22Submit%22%3A%22OK%22%7D&Submit=OK"
  end
end
