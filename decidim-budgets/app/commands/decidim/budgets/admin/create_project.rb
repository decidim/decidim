# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user creates a Project from the admin
      # panel.
      class CreateProject < Decidim::Command
        include ::Decidim::AttachmentMethods
        include ::Decidim::GalleryMethods

        def initialize(form)
          @form = form
        end

        # Creates the project if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          if process_gallery?
            build_gallery
            return broadcast(:invalid) if gallery_invalid?
          end

          transaction do
            create_project!
            link_proposals
            create_gallery if process_gallery?
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :project, :gallery

        def create_project!
          attributes = {
            budget: form.budget,
            scope: form.scope,
            category: form.category,
            title: form.title,
            description: form.description,
            budget_amount: form.budget_amount,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude
          }

          @project = Decidim.traceability.create!(
            Project,
            form.current_user,
            attributes,
            visibility: "all"
          )
          @attached_to = @project
        end

        def proposals
          @proposals ||= project.sibling_scope(:proposals).where(id: form.proposal_ids)
        end

        def link_proposals
          project.link_resources(proposals, "included_proposals")
        end
      end
    end
  end
end
