defmodule Particle do
  use GenServer
  import Nx.Defn

  defstruct [:swarm, :pos, :best_p, :best_g, :vel, :b_up, :b_down, :phi_p, :phi_g, :w, :fun]

  @type t :: %__MODULE__{
          swarm: pid(),
          pos: Nx.Tensor.t(),
          best_p: Nx.Tensor.t(),
          best_g: Nx.Tensor.t(),
          vel: Nx.Tensor.t(),
          b_up: number(),
          b_down: number(),
          phi_p: float(),
          phi_g: float(),
          w: float(),
          fun: fun()
        }

  @impl true
  def init(particle) do
    {:ok, particle}
  end

  @impl true
  def handle_call(:get, _from, particle), do: {:reply, particle, particle}
  def handle_call(:initialize, _from, particle), do: {:reply, self(), initialize(particle)}
  def handle_call(:set_vel, _from, particle), do: {:reply, self(), set_vel(particle)}
  def handle_call(:move, _from, particle), do: {:reply, self(), move(particle)}

  def handle_call(:get_best, _from, particle),
    do: {:reply, Nx.min(particle.best_p, particle.best_g), particle}

  @impl true
  def handle_cast({:set_best, global_best}, state), do: {:noreply, set_best(state, global_best)}

  @spec initialize(__MODULE__.t()) :: __MODULE__.t()
  def initialize(particle) do
    key = Nx.Random.key(:rand.uniform(256))
    {pos, new_key} = Nx.Random.uniform(key, particle.b_down, particle.b_up, shape: {2})
    {vel, _} = Nx.Random.uniform(new_key, particle.b_down, particle.b_up, shape: {2})

    %__MODULE__{particle | pos: pos, best_p: pos, best_g: pos, vel: vel}
  end

  @spec move(__MODULE__.t()) :: __MODULE__.t()
  def move(particle) do
    new_pos = move(particle.pos, particle.vel)

    new_best =
      if particle.fun.(new_pos) > particle.fun.(particle.pos) do
        particle.pos
      else
        new_pos
      end

    %__MODULE__{particle | pos: new_pos, best_p: new_best}
  end

  defn move(pos, vel) do
    pos + vel
  end

  @spec set_best(__MODULE__.t(), Nx.Tensor.t()) :: __MODULE__.t()
  def set_best(particle, global_best) do
    %__MODULE__{particle | best_g: global_best}
  end

  @doc """
  Updates the velocity of the particles

  $$
  v ← w v + φ_p r_p (p - x) + φ_g r_g (g - x)
  $$
  """
  @spec set_vel(__MODULE__.t()) :: __MODULE__.t()
  def set_vel(
        particle = %__MODULE__{
          pos: p,
          vel: v,
          best_p: bp,
          best_g: bg,
          w: w,
          phi_p: pp,
          phi_g: pg
        }
      ) do
    key = Nx.Random.key(256)
    {r_p, new_key} = Nx.Random.uniform(key)
    {r_g, _new_key} = Nx.Random.uniform(new_key)

    new_vel = calc_vel(p, v, bp, bg, w, pp, pg, r_p, r_g)
    %__MODULE__{particle | vel: new_vel}
  end

  defn calc_vel(p, v, bp, bg, w, pp, pg, r_p, r_g) do
    w * v + pp * r_p * (bp - p) + pg * r_g * (bg - p)
  end
end
