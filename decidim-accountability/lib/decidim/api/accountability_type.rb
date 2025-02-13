# frozen_string_literal: true

module Decidim
  module Accountability
    class AccountabilityType < Decidim::Core::ComponentType
      graphql_name "Accountability"
      description "An accountability component of a participatory space."

      field :result, Decidim::Accountability::ResultType, "A single Result object", null: true do
        argument :id, ID, "The id of the Result requested", required: true
      end
      field :results, Decidim::Accountability::ResultType.connection_type, "A collection of Results", null: true, connection: true

      def results
        Result.where(component: object).includes(:component)
      end

      def result(**args)
        Result.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
