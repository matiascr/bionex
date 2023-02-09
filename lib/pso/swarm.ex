defmodule Swarm do
  use GenServer

  defstruct [:num_ants, :b_up, :b_down, :phi_p, :phi_g]

  @type t :: %__MODULE__{
          num_ants: integer,
          b_up: number,
          b_down: number,
          phi_p: float,
          phi_g: float
        }

  @impl true
  def init(num_ants: num_ants, b_up: b_up, b_down: b_down, phi_p: phi_p, phi_g: phi_g) do
    {:ok, %__MODULE__{num_ants: num_ants}}
  end

  def initialize_particles() do
  end

  def set_local_best() do
  end

  def set_global_best() do
  end

  def set_velocity() do
  end

  def move() do
  end
end
