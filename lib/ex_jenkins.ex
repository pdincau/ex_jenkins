defmodule ExJenkins do
  use Application

  def start(_type, _args) do
    ExJenkins.Supervisor.start_link()
  end

  def base_url do
    host = Application.get_env(:ex_jenkins, :host)
    port = Application.get_env(:ex_jenkins, :port)
    protocol = Application.get_env(:ex_jenkins, :protocol) || "http"
    protocol <> "://" <> host <> ":" <> port <> "/"
  end

  def basic_auth_string do
    username = Application.get_env(:ex_jenkins, :username)
    password = Application.get_env(:ex_jenkins, :password)
    "Basic " <> Base.encode64("#{username}:#{password}")
  end

  def token do
    Application.get_env(:ex_jenkins, :token)
  end
end
