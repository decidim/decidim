# frozen_string_literal: true

module Decidim
  module Accountability
    class AccountabilityType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Accountability"
      description "An accountability component of a participatory space."

      field :results, ResultType.connection_type, null: true, connection: true

      def results
        ResultTypeHelper.base_scope(object).includes(:component)
      end

      field :result, ResultType, null: true do
        argument :id, ID, required: true
      end

      def result(**args)
        ResultTypeHelper.base_scope(object).find_by(id: args[:id])
      end
    end

    module ResultTypeHelper
      def self.base_scope(component)
        Result.where(component: component)
      end
    end
  end
end
