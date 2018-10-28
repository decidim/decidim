# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller that allows managing all the attachments for an initiative
      class InitiativeAttachmentsController < Decidim::Initiatives::Admin::ApplicationController
        include InitiativeAdmin
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          initiative_attachments_path(current_initiative)
        end

        def attached_to
          current_initiative
        end
      end
    end
  end
end
