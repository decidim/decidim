# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # process.
      #
      class AttachmentsController < Decidim::Blogs::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          post_attachments_path
        end

        def attached_to
          post
        end

        def post
          @post ||= posts.find(params[:post_id])
        end
      end
    end
  end
end
