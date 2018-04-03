# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller that allows managing all the attachments for an initiative
      class InitiativeAttachmentsController < Decidim::Admin::ApplicationController
        include InitiativeAdmin
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          initiative_attachments_path(current_initiative)
        end

        def attached_to
          current_initiative
        end

        def authorization_object
          collection.find_by(id: params[:id]) || Decidim::Attachment
        end
      end
    end
  end
end
