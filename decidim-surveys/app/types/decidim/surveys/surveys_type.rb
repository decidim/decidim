# frozen_string_literal: true

module Decidim
  module Surveys

    class SurveyEdge < GraphQL::Types::Relay::BaseEdge
      node_type(SurveyType)
    end

    class SurveyConnection < GraphQL::Types::Relay::BaseConnection
      edge_type(SurveyEdge)
    end

    class SurveysType < GraphQL::Schema::Object
      graphql_name "Survey"
      implements Decidim::Core::ComponentInterface
      description "A surveys component of a participatory space."

      field :surveys, SurveyConnection, null: false, connection: true do
        def resolve(object:, _args:, context:)
          SurveysTypeHelper.base_scope(object).includes(:component)
        end
      end

      field(:survey, SurveyType, null: true) do
        argument :id, ID, required: true
        def resolve(object:, _args:, context:)
          SurveysTypeHelper.base_scope(object).includes(:component).find_by(id: _args[:id])
        end
      end

    end

    module SurveysTypeHelper
      def self.base_scope(component)
        Survey.where(component: component)
      end
    end
  end
end
