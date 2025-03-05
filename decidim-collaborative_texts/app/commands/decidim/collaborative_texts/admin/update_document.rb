# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user changes a Document from the admin
      # panel.
      class UpdateDocument < Decidim::Commands::UpdateResource
        protected

        def update_resource
          # As traceability might not understand the body attribute, we save it separately
          if form.title != resource.title || form.accepting_suggestions != resource.accepting_suggestions
            Decidim.traceability.update!(
              resource,
              current_user,
              {
                title: form.title,
                accepting_suggestions: form.accepting_suggestions
              },
              **extra_document_params
            )
          end

          if form.draft != resource.draft
            Decidim.traceability.update!(
              resource.current_version,
              current_user,
              { draft: form.draft },
              **extra_document_params
            )
          end
          # Body can only be updated if the document has no suggestions
          return if form.body == resource.body || resource.has_suggestions?

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
