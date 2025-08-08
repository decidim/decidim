# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user changes a Project from the admin
      # panel.
      class UpdateProject < Decidim::Commands::UpdateResource
        include ::Decidim::GalleryMethods
        fetch_form_attributes :taxonomizations, :title, :description, :budget_amount, :address, :latitude, :longitude

        def initialize(form, project)
          super
          @attached_to = project
        end

        private

        def run_after_hooks
          link_proposals
          create_gallery if process_gallery?
          photo_cleanup!
        end

        def run_before_hooks
          return unless process_gallery?

          build_gallery
          raise Decidim::Commands::HookError if gallery_invalid?
        end

        def attributes
          super.merge({ selected_at: })
        end

        def proposals
          @proposals ||= resource.sibling_scope(:proposals).where(id: form.proposal_ids)
        end

        def link_proposals
          resource.link_resources(proposals, "included_proposals")
        end

        def selected_at
          return unless form.selected

          Time.current
        end
      end
    end
  end
end
