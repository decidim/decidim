# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user creates a Project from the admin
      # panel.
      class CreateProject < Decidim::Commands::CreateResource
        include ::Decidim::GalleryMethods
        fetch_form_attributes :budget, :taxonomizations, :title, :description, :budget_amount, :address, :latitude, :longitude

        private

        attr_reader :gallery

        def run_after_hooks
          @attached_to = resource
          link_proposals
          create_gallery if process_gallery?
        end

        def run_before_hooks
          return unless process_gallery?

          build_gallery
          raise Decidim::Commands::HookError if gallery_invalid?
        end

        def extra_params
          { visibility: "all" }
        end

        def resource_class = Decidim::Budgets::Project

        def proposals
          @proposals ||= resource.sibling_scope(:proposals).where(id: form.proposal_ids)
        end

        def link_proposals
          resource.link_resources(proposals, "included_proposals")
        end
      end
    end
  end
end
