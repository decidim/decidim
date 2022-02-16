# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user updates an Election
      # from the admin panel.
      class UpdateElection < Decidim::Command
        include ::Decidim::AttachmentMethods
        include ::Decidim::GalleryMethods

        def initialize(form, election)
          @form = form
          @election = election
          @attached_to = election
        end

        # Updates the election if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          if process_gallery?
            build_gallery
            return broadcast(:invalid) if gallery_invalid?
          end

          transaction do
            update_election!
            create_gallery if process_gallery?
            photo_cleanup!
          end

          broadcast(:ok, election)
        end

        private

        attr_reader :form, :election, :gallery

        def update_election!
          attributes = {
            title: form.title,
            description: form.description,
            start_time: form.start_time,
            end_time: form.end_time
          }

          Decidim.traceability.update!(
            election,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
