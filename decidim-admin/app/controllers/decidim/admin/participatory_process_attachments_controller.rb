# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the attachments for a participatory
    # process.
    #
    class ParticipatoryProcessAttachmentsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin
      include Concerns::HasAttachments

      def attached_to
        participatory_process
      end

      def authorization_object
        @attachment || Attachment
      end
    end
  end
end
