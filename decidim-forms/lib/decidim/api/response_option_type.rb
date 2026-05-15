# frozen_string_literal: true

module Decidim
  module Forms
    class ResponseOptionType < Decidim::Api::Types::BaseObject
      description "An response option for a multi-choice question in a questionnaire"

      field :body, Decidim::Core::TranslatedFieldType, "The response option text.", null: false
      field :free_text, GraphQL::Types::Boolean, "Whether if this response accepts any free text from the user.", null: false
      field :id, GraphQL::Types::ID, "ID of this response option", null: false
    end
  end
end
