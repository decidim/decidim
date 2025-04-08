# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This command is executed when the user creates a Document from the admin
    # panel.
    class CreateSuggestion < Decidim::Commands::CreateResource
      fetch_form_attributes :author, :document_version, :changeset

      private

      def resource_class = Decidim::CollaborativeTexts::Suggestion

      def extra_params
        {
          participatory_space: {
            title: document&.participatory_space&.title
          },
          resource: {
            title: document&.title
          }
        }
      end
    end
  end
end
