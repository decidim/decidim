# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # Controller that allows managing all the attachment collections for a budget.
      #
      class AttachmentCollectionsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections

        def after_destroy_path
          project_attachment_collections_path(project, project.component, current_participatory_space)
        end

        def collection_for
          project
        end

        def project
          @project ||= Decidim::Budgets::Project.find(params[:project_id])
        end
      end
    end
  end
end
