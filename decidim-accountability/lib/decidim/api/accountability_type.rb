# frozen_string_literal: true

module Decidim
  module Accountability
    class AccountabilityType < Decidim::Core::ComponentType
      graphql_name "Accountability"
      description "An accountability component of a participatory space."

      field :results, Decidim::Accountability::ResultType.connection_type, null: true, connection: true

      field :result, Decidim::Accountability::ResultType, null: true do
        argument :id, ID, required: true
      end

      def results
        Result.where(component: object).includes(:component)
      end

      def result(**args)
        Result.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
