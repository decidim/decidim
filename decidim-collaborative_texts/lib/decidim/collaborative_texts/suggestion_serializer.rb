# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class SuggestionSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper

      def serialize
        {
          id: resource.id,
          document_id: resource.document.id,
          document_title: resource.document.title,
          original_text: resource.changeset["original"]&.join("\n")&.strip,
          replacement_text: resource.changeset["replace"]&.join("\n")&.strip,
          first_node: resource.changeset["firstNode"],
          last_node: resource.changeset["lastNode"],
          author: author_fields,
          status: resource.status,
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      end

      private

      def author_fields
        return {} unless resource.author

        {
          id: resource.author.id,
          name: author_name(resource.author),
          email: resource.author.try(:email)
        }
      end

      def author_name(author)
        translated_attribute(author.name)
      end
    end
  end
end
