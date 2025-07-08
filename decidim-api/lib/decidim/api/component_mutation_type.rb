# frozen_string_literal: true

module Decidim
  module Api
    class ComponentMutationType < GraphQL::Schema::Union
      description "A component mutation."

      possible_types Decidim::Proposals::ProposalsMutationType,
                     Decidim::Budgets::BudgetsMutationType # ,
      def self.resolve_type(obj, _ctx)
        case obj.manifest_name
        when "proposals"
          Decidim::Proposals::ProposalsMutationType
        when "budgets"
          Decidim::Budgets::BudgetsMutationType
        when "accountability"
          Decidim::Accountability::AccountabilityMutationType
        end
      end
    end
  end
end
