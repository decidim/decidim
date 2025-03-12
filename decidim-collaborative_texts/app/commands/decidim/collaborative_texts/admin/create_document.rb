# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user creates a Document from the admin
      # panel.
      class CreateDocument < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :body, :component

        private

        def resource_class = Decidim::CollaborativeTexts::Document

        def run_after_hooks
          # ensure the first author is always the organization in case "official?" is ever used
          resource.add_coauthor(resource.organization)
        end

        def extra_params
          {
            extra: {
              body: form.body
            }
          }
        end
      end
    end
  end
end
