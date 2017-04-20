defmodule ExJenkins.CrumbServer do

  use GenServer

  alias ExJenkins.Crumb

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def crumb_info do
    GenServer.call(__MODULE__, :crumb_info)
  end

  def init(:ok) do
    send(self(), :set_crumb_info)
    {:ok, %{value: nil, request_field: nil}}
  end

  def handle_call(:crumb_info, _from, crumb_info) do
    {:reply, {:ok, crumb_info}, crumb_info}
  end

  def handle_info(:set_crumb_info, crumb_info) do
    {:ok, {{:value, value}, {:request_field, request_field}}} = Crumb.issue
    {:noreply, %{crumb_info| value: value, request_field: request_field}}
  end

end
