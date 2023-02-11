defmodule Particle do
  use GenServer

  defstruct [:swarm, :pos, :best, :v, :b_up, :b_down, :phi_p, :phi_g]

  @type t :: %__MODULE__{
          swarm: pid(),
          pos: Nx.Tensor.t(),
          best: Nx.Tensor.t(),
          v: Nx.Tensor.t(),
          b_up: number(),
          b_down: number(),
          phi_p: float(),
          phi_g: float()
        }

  @impl true
  def init(particle) do
    {:ok, particle}
  end

  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_call(:initialize, _from, state) do
    particle = initialize(state)
    {:reply, particle, particle}
  end

  def initialize(particle) do
    key = Nx.Random.key(:rand.uniform(256))
    {pos, new_key} = Nx.Random.uniform(key, particle.b_down, particle.b_up, shape: {2})
    {v, _} = Nx.Random.uniform(new_key, particle.b_down, particle.b_up, shape: {2})

    %__MODULE__{particle | pos: pos, best: pos, v: v}
  end
end
