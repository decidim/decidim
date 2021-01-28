# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveysType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Surveys"
      description "A surveys component of a participatory space."

      field :surveys, Decidim::Surveys::SurveyType.connection_type, null: true, connection: true

      def surveys
        Survey.where(component: object).includes(:component)
      end

      field :survey, Decidim::Surveys::SurveyType, null: true do
        argument :id, GraphQL::Types::ID, required: true
      end

      def survey(**args)
        Survey.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
