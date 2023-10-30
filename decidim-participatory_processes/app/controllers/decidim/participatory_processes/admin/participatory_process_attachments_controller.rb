# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # process.
      #
      class ParticipatoryProcessAttachmentsController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::Concerns::HasAttachments
        include Decidim::Admin::Concerns::HasTabbedMenu

        def after_destroy_path
          participatory_process_attachments_path(current_participatory_process)
        end

        def attached_to
          current_participatory_process
        end

        private

        def tab_menu_name = :participatory_process_admin_attachments_menu
      end
    end
  end
end
