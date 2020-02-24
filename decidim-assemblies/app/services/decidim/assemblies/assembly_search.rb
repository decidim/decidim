# frozen_string_literal: true

module Decidim
  module Assemblies
    # Service that encapsulates all logic related to filtering assemblies.
    class AssemblySearch < ParticipatorySpaceSearch
      def initialize(options = {})
        super(Assembly.all, options)
      end

      def search_type_id
        return query if type_id.blank?

        query.where(decidim_assemblies_type_id: type_id)
      end
    end
  end
end
