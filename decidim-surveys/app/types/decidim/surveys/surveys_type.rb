# frozen_string_literal: true

module Decidim
  module Surveys
    SurveysType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Surveys"
      description "A surveys component of a participatory space."

      connection :surveys, SurveyType.connection_type do
        resolve ->(component, _args, _ctx) {
                  SurveysTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:survey, SurveyType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          SurveysTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module SurveysTypeHelper
      def self.base_scope(component)
        Survey.where(component: component)
      end
    end
  end
end
