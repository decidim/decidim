# frozen_string_literal: true

module Decidim
  module Assemblies
    # Service that encapsulates all logic related to filtering assemblies.
    class AssemblySearch < SpaceSearch
      def initialize(options = {})
        super(Assembly.all, options)
      end

      # Creates the SearchLight base query.
      # def base_query
      #   Assembly.includes(:scope).where(organization: options[:organization])
      # end

      def search_assembly_type
      # puts "\n\n\n\n\n\n\n HELLOOOOOOO \n\n\n\n\n\n\n\n\n"
        return query if assembly_type == "all"

        query.where(assembly_type: assembly_type)
      end

    def search_scope_id
      raise
    end
    end
  end
end
