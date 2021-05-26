# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # Controller that allows managing all the attachment collections for an
      # accountability result.
      #
      class AttachmentCollectionsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections

        def after_destroy_path
          result_attachment_collections_path(result, result.component, current_participatory_space)
        end

        def collection_for
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
