# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Adds some filter values for participatory_processes
    class ParticipatoryProcessList < Decidim::Core::ParticipatorySpaceListBase
      argument :filter, ParticipatoryProcessInputFilter, "This argument let's you filter the results"
      argument :order, ParticipatoryProcessInputSort, "This argument let's you order the results"
    end
  end
end
