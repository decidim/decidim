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

          # Admin forcing a draft to discard existing suggestions
          if resource.has_suggestions? && form.draft
            Decidim.traceability.create!(
              Decidim::CollaborativeTexts::Version,
              current_user,
              { document: resource, body: resource.body, draft: true },
              **extra_version_params
            )
          else
            Decidim.traceability.update!(
              resource.current_version,
              current_user,
              { draft: form.draft, body: form.body },
              **extra_version_params
            )
          end
        end

        def extra_document_params
          {
            extra: {
              version_id: resource.current_version&.id,
              version_number: current_version_number
            }
          }
        end

        def extra_version_params
          {
            extra: {
              document_id: resource.id,
              title: resource.title,
              version_number: current_version_number
            },
            resource: {
              title: resource.title
            },
            participatory_space: {
              title: resource.participatory_space.title
            }
          }
        end

        def current_version_number
          resource.current_version&.version_number || 1
        end
      end
    end
  end
end
