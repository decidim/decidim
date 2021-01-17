# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Adds slug finder for participatory_processes
    class ParticipatoryProcessFinder < Decidim::Core::ParticipatorySpaceFinder
      argument :slug, String, "The slug of the participatory process"
    end
  end
end
