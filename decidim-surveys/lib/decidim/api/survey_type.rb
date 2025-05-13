# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveyType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      description "A survey"

      field :id, GraphQL::Types::ID, "The internal ID for this survey", null: false
      field :questionnaire, Decidim::Forms::QuestionnaireType, "The questionnaire for this survey", null: true
      field :url, GraphQL::Types::String, "The URL for this survey", null: false

      def url
        Decidim::ResourceLocatorPresenter.new(object).url
      end

      def self.authorized?(object, context)
        context[:survey] = object
        context[:current_settings] = object.component.current_settings

        super
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end
    end
  end
end
