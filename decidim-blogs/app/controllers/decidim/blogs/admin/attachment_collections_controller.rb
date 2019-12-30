# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # Controller that allows managing all the attachment collections for an assembly.
      #
      class AttachmentCollectionsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections

        def after_destroy_path
          post_attachment_collections_path(post, post.component, current_participatory_space)
        end

        def collection_for
          post
        end

        def post
          @post ||= posts.find(params[:post_id])
        end
      end
    end
  end
end
