# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user changes a Document from the admin
      # panel.
      class UpdateDocument < Decidim::Commands::UpdateResource
        fetch_form_attributes :title, :body

        protected

        def update_resource
          # As traceability might not understand the body attribute, we save it separately
          if form.title != resource.title
            Decidim.traceability.update!(
              resource,
              current_user,
              { title: form.title },
              **extra_document_params
            )
          end
          return unless form.body != resource.body

          Decidim.traceability.update!(
            resource.current_version,
            current_user,
            { body: form.body },
            **extra_version_params
          )
        end

        def extra_document_params
          {
            extra: {
              version_id: resource.current_version&.id,
              version_number: resource.current_version&.version_number
            }
          }
        end

        def extra_version_params
          {
            extra: {
              document_id: resource.id,
              title: resource.title,
              version_number: resource.current_version&.version_number
            }
          }
        end
      end
    end
  end
end
