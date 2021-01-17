# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveysType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Surveys"
      description "A surveys component of a participatory space."

      field :surveys, SurveyType.connection_type, null: true, connection: true

      def surveys
        SurveysTypeHelper.base_scope(object).includes(:component)
      end

      field :survey, SurveyType, null: true do
        argument :id, ID, required: true
      end

      def survey(**args)
        SurveysTypeHelper.base_scope(object).find_by(id: args[:id])
      end
    end

    module SurveysTypeHelper
      def self.base_scope(component)
        Survey.where(component: component)
      end
    end
  end
end
