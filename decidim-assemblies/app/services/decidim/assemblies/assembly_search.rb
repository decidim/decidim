# frozen_string_literal: true

module Decidim
  module Assemblies
    # Service that encapsulates all logic related to filtering assemblies.
    class AssemblySearch < ParticipatorySpaceSearch
      def initialize(options = {})
        super(Assembly.all, options)
      end

      def search_assembly_type
        return query if assembly_type == "all"

        query.where(assembly_type: assembly_type)
      end
    end
  end
end
