# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user updates an Answer
      # from the admin panel.
      class UpdateAnswer < Decidim::Command
        include ::Decidim::AttachmentMethods
        include ::Decidim::GalleryMethods

        def initialize(form, answer)
          @form = form
          @answer = answer
          @attached_to = answer
        end

        # Updates the answer if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          if process_gallery?
            build_gallery
            return broadcast(:invalid) if gallery_invalid?
          end

          transaction do
            update_answer
            link_proposals
            create_gallery if process_gallery?
            photo_cleanup!
          end

          broadcast(:ok, answer)
        end

        private

        attr_reader :form, :answer, :gallery

        def invalid?
          form.election.started? || form.invalid?
        end

        def update_answer
          attributes = {
            question: form.question,
            title: form.title,
            description: form.description,
            weight: form.weight
          }

          Decidim.traceability.update!(
            answer,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end

        def proposals
          @proposals ||= answer.sibling_scope(:proposals).where(id: form.proposal_ids)
        end

        def link_proposals
          answer.link_resources(proposals, "related_proposals")
        end
      end
    end
  end
end
