defmodule Virt.Ecto.Type.IPv4 do
  @moduledoc """
  Ecto.Type behavior to translate between integers and dot notations
  """

  @behaviour Ecto.Type

  # this could get refactored to use 255^0 to 255^3
  @first 256 * 256 * 256
  @second 256 * 256
  @third 256
  @fourth 1

  @doc false
  def type, do: :string

  @doc false
  def cast(value), do: {:ok, value}

  @doc """
  Load IP from the database converting from integer to string.

  """
  def load(value) when is_integer(value) do
    with first when first >= 0 and first <= 255 <- div(value, @first),
         second when second >= 0 and second <= 255 <- div(Integer.mod(value, @first), @second),
         third when third >= 0 and third <= 255 <- div(Integer.mod(value, @second), @third),
         fourth when fourth >= 0 and fourth <= 255 <- div(Integer.mod(value, @third), @fourth) do
      ip =
        {first, second, third, fourth}
        |> :inet.ntoa()
        |> to_string()

      {:ok, ip}
    else
      _ -> :error
    end
  end

  def load(_), do: :error

  @doc """
  Converts an IP as a string into an integer to write out to the database.

  ## Example

  ```
  iex(3)> Virt.Ecto.Type.IPv4.dump("10.0.0.0")
  {:ok, 167772160}
  ```
  """
  def dump(value) when is_bitstring(value) do
    parsed =
      value
      |> to_charlist()
      |> :inet.parse_ipv4strict_address()

    case parsed do
      {:ok, {first, second, third, fourth}} ->
        {:ok,
          first * @first +
          second * @second +
          third * @third +
          fourth * @fourth
        }

      _ ->
        :error
    end
  end

  def dump(_), do: :error

  # default equal?
  def equal?(value1, value2) do
    value1 == value2
  end

  # use a default embed_as, if issues with embedding ipv4 look at changing this
  def embed_as(_), do: :self
end
