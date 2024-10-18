# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      class UnpublishPost < Decidim::Command
        # Public: Initializes the command.
        #
        # meeting - Decidim::Meetings::Meeting
        # current_user - the user performing the action
        def initialize(post, current_user)
          @post = post
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless post.published?

          @post = Decidim.traceability.perform_action!(
            :unpublish,
            post,
            current_user,
            visibility: "all"
          ) do
            post.unpublish!
            post
          end
          broadcast(:ok, post)
        end

        private

        attr_reader :post, :current_user
      end
    end
  end
end
