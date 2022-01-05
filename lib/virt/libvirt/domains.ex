defmodule Virt.Libvirt.Domains do
  @moduledoc """
  The Libvirt.Domains context.
  """

  import Ecto.Query, warn: false
  require Logger

  alias Virt.Repo

  alias Virt.Libvirt.Domains.Domain
  alias Virt.Libvirt.Templates

  @doc """
  Returns the list of domains.
  """
  def list_domains do
    Repo.all(Domain)
  end

  @doc """
  Gets a single domain.

  Raises `Ecto.NoResultsError` if the Domain does not exist.
  """
  def get_domain!(id), do: Repo.get!(Domain, id)

  @doc """
  Creates a domain.
  """
  def create_domain(attrs \\ %{}) do
    with changeset <- Domain.changeset(%Domain{}, attrs),
         {:ok, domain} <- Repo.insert(changeset),
         domain <- Repo.preload(domain, [:host, domain_disks: [:volume]]),
         {:ok, _} <- create_libvirt_domain(domain),
         {:ok, domain} <- update_domain(domain, %{"created" => true})
    do
      {:ok, domain}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, error, %Domain{} = domain} ->
        Logger.error(error)
        delete_domain(domain)
        {:error, error}
    end
  end

  defp create_libvirt_domain(domain) do
    with xml <- Templates.render_domain(domain),
         {:ok, socket} <- Libvirt.connect(domain.host.connection_string),
         {:ok, %{"remote_nonnull_domain" => libvirt_domain}} <- Libvirt.domain_create_xml(socket, %{"xml_desc" => xml, "flags" => 0})
    do
      {:ok, libvirt_domain}
    else
      {:error, %Libvirt.RPC.Packet{payload: error}} ->
        {:error, error, domain}
      {:error, :econnrefused} ->
        {:error, "Could not connect to Libvirt host #{domain.host.connection_string}"}
      error -> {:error, error, domain}
    end
  end

  @doc """
  Updates a domain.
  """
  def update_domain(%Domain{} = domain, attrs) do
    domain
    |> Domain.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a domain.
  """
  def delete_domain(%Domain{} = domain) do
    with :ok <- delete_libvirt_domain(domain),
         {:ok, domain} <- Repo.delete(domain)
    do
      {:ok, domain}
    end
  end

  defp delete_libvirt_domain(domain) do
    with domain <- Repo.preload(domain, [:host]),
         {:ok, socket} <- Libvirt.connect(domain.host.connection_string),
         {:ok, nil} <- Libvirt.domain_destroy(socket, %{"dom" => %{"name" => domain.name, "uuid" => domain.id, "id" => -1}})
    do
      :ok
    else
      {:error, packet} ->
        # also delete volume if storage pool does not exist
        if packet.payload =~ "VIR_ERR_NO_DOMAIN" do
          Repo.delete(domain)
        else
          {:error, packet}
        end
      error -> {:error, error}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking domain changes.
  """
  def change_domain(%Domain{} = domain, attrs \\ %{}) do
    Domain.changeset(domain, attrs)
  end
end
