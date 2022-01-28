defmodule AmpsLib do
  alias AmpsLib.IniManager
  @moduledoc """
  Documentation for `AmpsLib`.
  """

  @doc """
  Load contents from INI File

  ## Examples

      iex> AmpsLib.load_ini(filename)
      returns map

  """
  def initialize(filename) do
    IniManager.load_ini(filename)
  end


end
