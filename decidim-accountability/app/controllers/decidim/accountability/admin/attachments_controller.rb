# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # Controller that allows managing all the attachments for an
      # accountability result.
      #
      class AttachmentsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          results_path
        end

        def attached_to
          result
        end

        def result
          @result ||= results.find(params[:result_id])
        end

        private

        def results
          @results ||= Result.where(component: current_component)
        end
      end
    end
  end
end
