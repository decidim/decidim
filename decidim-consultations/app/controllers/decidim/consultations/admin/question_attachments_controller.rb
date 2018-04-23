# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing all the attachments for a question
      class QuestionAttachmentsController < Decidim::Admin::ApplicationController
        include QuestionAdmin
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          decidim_admin_consultations.question_attachments_path(current_question)
        end

        def attached_to
          current_question
        end

        def authorization_object
          collection.find_by(id: params[:id]) || Decidim::Attachment
        end

        def current_participatory_space_manifest_name
          :consultations
        end
      end
    end
  end
end
