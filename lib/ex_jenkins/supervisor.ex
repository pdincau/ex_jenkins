defmodule ExJenkins.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children =
      case Mix.env() do
        :test -> []
        _ -> [worker(ExJenkins.CrumbServer, [], restart: :permanent)]
      end

    supervise(children, strategy: :one_for_one)
  end
end
