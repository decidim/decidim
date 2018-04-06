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

        def after_destroy_path
          participatory_process_attachments_path(current_participatory_process)
        end

        def attached_to
          current_participatory_process
        end
      end
    end
  end
end
