# frozen_string_literal: true

module Decidim
  module Accountability
    class AccountabilityMutationType < Decidim::Api::Types::BaseObject
      graphql_name "AccountabilityMutation"
      description "Accountability mutations"

      field :results, Decidim::Accountability::ResultType.connection_type, "A collection of Results", null: true, connection: true

      def results
        Result.where(component: object).includes(:component)
      end
    end
  end
end
