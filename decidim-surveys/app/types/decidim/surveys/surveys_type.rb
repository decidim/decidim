# frozen_string_literal: true

module Decidim
  module Surveys

    class SurveysType < GraphQL::Schema::Object
      graphql_name "Survey"
      interfaces [-> { Decidim::Core::ComponentInterface }]
      description "A surveys component of a participatory space."

      field :surveys, SurveyType.connection_type, null: false
      field(:survey, SurveyType, null: true ) do
        argument :id, ID, required: true
      end

      def surveys
        SurveysTypeHelper.base_scope(object).includes(:component)
      end

      def survey(id:)
        survey.find_by(id: id)
      end
    end

    module SurveysTypeHelper
      def self.base_scope(component)
        Survey.where(component: component)
      end
    end
  end
end
