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
      field :status, Decidim::Accountability::StatusType, "A single Status object", null: true do
        argument :id, ID, "The id of the Status requested", required: true
      end
      field :statuses, [Decidim::Accountability::StatusType], "The Statuses for this component", null: false

      def results
        Result.where(component: object).includes(:component)
      end

      def result(**args)
        Result.where(component: object).find_by(id: args[:id])
      end

      def statuses
        Status.where(component: object).order(:progress, :key, :id)
      end

      def status(id:)
        Status.where(component: object).find_by(id:)
      end
    end
  end
end
