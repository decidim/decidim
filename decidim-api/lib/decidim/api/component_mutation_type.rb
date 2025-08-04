# frozen_string_literal: true

module Decidim
  module Api
    class ComponentMutationType < GraphQL::Schema::Union
      description "A component mutation."

      possible_types Decidim::Proposals::ProposalsMutationType # ,
      #  ::Decidim::Api::Budgets::BudgetsMutationType,
      #  ::Decidim::Api::Accountability::AccountabilityMutationType

      def self.resolve_type(obj, _ctx)
        mod = obj.manifest_name.camelize
        "Decidim::#{mod}::#{mod}MutationType".constantize
      rescue NameError
        Rails.logger.warn("Mutation type not found for #{mod}: #{e.message}")
        nil
      end
    end
  end
end
