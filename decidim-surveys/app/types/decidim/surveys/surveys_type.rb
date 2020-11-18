# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveysType < GraphQL::Schema
      # graphql_name "Survey"
      # implements Decidim::Core::ComponentInterface
      # description "A surveys component of a participatory space."
      use GraphQL::Pagination::Connections

      # field :surveys, SurveyType.connection_type, null: false, connection: true
      #
      #
      # field(:survey, SurveyType , null: true) do
      #   argument :id, ID, required: true
      #   def resolve(object:, _args:, context:)
      #     SurveysTypeHelper.base_scope(object).includes(:component).find_by(id: _args[:id])
      #   end
      # end
      # def surveys
      #   object.surveys  # => eg, returns an ActiveRecord Relation
      # end
    end

    module SurveysTypeHelper
      def self.base_scope(component)
        Survey.where(component: component)
      end
    end
  end
end
