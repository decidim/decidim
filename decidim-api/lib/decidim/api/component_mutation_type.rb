# frozen_string_literal: true

module Decidim
  module Api
    class ComponentMutationType < GraphQL::Schema::Union
      description "A component mutation."

      possible_types(*Decidim::MutationRegistry.instance.mutation_types)

      def self.resolve_type(obj, _ctx)
        mod = obj.manifest_name.camelize
        "Decidim::#{mod}::#{mod}MutationType".constantize
      rescue NameError
        raise GraphQL::ExecutionError, "Mutation type not found for #{mod}"
      end
    end
  end
end
