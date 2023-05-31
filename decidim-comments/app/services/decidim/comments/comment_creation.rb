# frozen_string_literal: true

module Decidim
  module Comments
    # This is a helper class in order to publish comment creation events
    # so that components can react to these successes and perform whatever they are required to.
    class CommentCreation
      EVENT_NAME = "decidim.comments.comment_created"

      # Publishes the event to ActiveSupport::Notifications.
      #
      # comment - The Decidim::Comments::Comment that has just been created.
      # metadatas - The hash of metadatas returned by the ContentProcessor after parsing
      #   this `comment`.
      def self.publish(comment, metadatas)
        ActiveSupport::Notifications.publish(
          EVENT_NAME,
          comment_id: comment.id,
          metadatas:
        )
      end

      # Creates a subscription to events for created comments.
      #
      # block - The block to be executed when a comment is created.
      def self.subscribe(&block)
        ActiveSupport::Notifications.subscribe(EVENT_NAME) do |_event_name, data|
          block.call(data)
        end
      end
    end
  end
end
