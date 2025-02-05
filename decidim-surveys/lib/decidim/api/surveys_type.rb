# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveysType < Decidim::Core::ComponentType
      graphql_name "Surveys"
      description "A surveys component of a participatory space."

      field :survey, Decidim::Surveys::SurveyType, "A single Survey object", null: true do
        argument :id, GraphQL::Types::ID, required: true
      end
      field :surveys, Decidim::Surveys::SurveyType.connection_type, "A collection of Surveys", null: true, connection: true

      def surveys
        Survey.where(component: object).includes(:component)
      end

      def survey(**args)
        Survey.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
