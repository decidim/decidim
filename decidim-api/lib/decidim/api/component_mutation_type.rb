# frozen_string_literal: true

module Decidim
  module Api
    class ComponentMutationType < GraphQL::Schema::Union
      description "A component mutation."

      possible_types Decidim::Api::Proposals::ProposalsMutationType # ,
      #  ::Decidim::Api::Budgets::BudgetsMutationType,
      #  ::Decidim::Api::Accountability::AccountabilityMutationType

      def self.resolve_type(obj, _ctx)
        case obj.manifest_name
        when "proposals"
          Decidim::Api::Proposals::ProposalsMutationType
          # when "budgets"
          #   Decidim::Api::Budgets::BudgetsMutationType
          # when "accountability"
          #   Decidim::Api::Accountability::AccountabilityMutationType
        end
      end
    end
  end
end
