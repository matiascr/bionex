defmodule Queen do
  def run(num_iter, num_ants, fun) do
    {:ok, pid} = GenServer.start_link(Swarm, num_ants: 4)

    pid
    |> initialize()
    |> iterate(num_iter)
    |> get_result()
  end

  def initialize(pid) do
    # something
    pid
  end

  def iterate(pid, num_iter) do
    # something
    pid
  end

  def get_result(pid) do
    # something
    pid
  end
end
