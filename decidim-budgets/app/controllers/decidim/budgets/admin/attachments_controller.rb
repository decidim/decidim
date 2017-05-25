# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # process.
      #
      class AttachmentsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          projects_path
        end

        def attached_to
          project
        end

        def project
          @project ||= projects.find(params[:project_id])
        end

        def authorization_object
          project.feature
        end
      end
    end
  end
end
