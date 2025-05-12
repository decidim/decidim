# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveyType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      description "A survey"

      field :allow_editing_responses, GraphQL::Types::Boolean, "Whether this survey accepts editing responses or not.", null: true
      field :allow_responses, GraphQL::Types::Boolean, "Whether this survey accepts responses or not.", null: true
      field :allow_unregistered, GraphQL::Types::Boolean, "Whether this survey accepts answers or not.", null: true
      field :announcement, Decidim::Core::TranslatedFieldType, "The announcement info for this survey", null: true
      field :ends_at, Decidim::Core::DateTimeType, "The time this survey ends accepting answers", null: true
      field :id, GraphQL::Types::ID, "The internal ID for this survey", null: false
      field :published_at, Decidim::Core::DateTimeType, description: "The date and time this survey was published", null: true
      field :questionnaire, Decidim::Forms::QuestionnaireType, "The questionnaire for this survey", null: true
      field :starts_at, Decidim::Core::DateTimeType, "The time this survey starts accepting answers", null: true
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
