# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module Admin
      # This command is executed when the user changes a Document from the admin
      # panel.
      class UpdateDocument < Decidim::Commands::UpdateResource
        protected

        def update_resource
          # Attributes to the model Document
          update_document_record!
          # As traceability might not understand the (delegated) body attribute, we save it separately
          if create_new_version?
            create_draft_version!
          else
            update_version_record!
          end
        end

        def create_new_version?
          @create_new_version ||= resource.has_suggestions? && form.draft?
        end

        def update_document_record!
          return unless form.title != resource.title || form.accepting_suggestions != resource.accepting_suggestions

          # this is a safe-guard in case there are no coauthors
          resource.coauthorships = form.coauthorships if resource.coauthorships.blank?

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

        # When the document is not a draft or it has no suggestions, we just update the current version
        def update_version_record!
          attributes = { draft: form.draft? }
          attributes[:body] = form.body unless resource.has_suggestions?
          Decidim.traceability.update!(
            resource.current_version,
            current_user,
            attributes,
            **extra_version_params
          )
        end

        # A new version is necessary when the document has suggestions and we want a draft (so we can edit it)
        # If we allow to edit a version with suggestions all the reference nodes to the DOM will be out of sync
        # Note that we do not update the body in purpose, as it is edition is disabled in the UI
        def create_draft_version!
          Decidim.traceability.create!(
            Decidim::CollaborativeTexts::Version,
            current_user,
            { document: resource, body: resource.body, draft: true },
            **extra_version_params
          )
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
          @current_version_number ||= begin
            num = resource.current_version&.version_number || 1
            create_new_version? ? num + 1 : num
          end
        end
      end
    end
  end
end
