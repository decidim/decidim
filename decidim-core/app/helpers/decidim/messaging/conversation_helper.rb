# frozen_string_literal: true

module Decidim
  module Messaging
    module ConversationHelper
      #
      # Generates a visualization of users for listing conversations threads
      #
      def username_list(users, shorten = false)
        return users.pluck(:name).join(", ") unless shorten
        return users.pluck(:name).join(", ") unless users.count > 3

        "#{users.first(3).pluck(:name).join(", ")} + #{users.count - 3}"
      end

      #
      # Links to the conversation between the current user and another user
      #
      def link_to_current_or_new_conversation_with(user, title = t("decidim.contact"))
        conversation_path = current_or_new_conversation_path_with(user)
        if conversation_path
          link_to conversation_path, title: title do
            icon "envelope-closed", aria_label: title, class: "icon--small"
          end
        else
          content_tag :span, title: t("decidim.user_contact_disabled"), data: { tooltip: true } do
            icon "envelope-closed", aria_label: title, class: "icon--small muted"
          end
        end
      end

      #
      # Finds the right path to the conversation the current user and another
      # user (the interlocutor).
      #
      # * If there's no current user, it returns to the login form path.
      #
      # * If there's a prior existing conversation between the users it returns
      #   the path to the existing conversation.
      #
      # * If there's no prior conversation between the users, it checks if the
      #   the interlocutor accepts the current user to new conversation.
      #   If affirmative, it returns the new conversation form path.
      #
      # * Otherwise returns nil, meaning that no conversation can be established
      #   with the interlocutor
      #
      # @param user [Decidim::User] The user to link to a conversation with
      #
      # @return [String] The resulting route
      #
      def current_or_new_conversation_path_with(user)
        decidim_routes = Decidim::Core::Engine.routes.url_helpers
        return decidim_routes.new_user_session_path unless user_signed_in?

        conversation = conversation_between(current_user, user)

        if conversation
          decidim_routes.conversation_path(conversation)
        elsif user.accepts_conversation?(current_user)
          decidim_routes.new_conversation_path(recipient_id: user.id)
        end
      end

      #
      # Finds the conversation between the given participants
      #
      # @param participants [Array<Decidim::User>] The participants to find a
      #   conversation between.
      #
      # @return [Decidim::Messaging::Conversation]
      def conversation_between(*participants)
        return if participants.to_set.length <= 1

        UserConversations.for(participants.first).find do |conversation|
          conversation.participants.to_set == participants.to_set
        end
      end

      #
      # Links to the conversation between the current user and another users group
      #
      def current_or_new_conversation_path_with_multiple(users)
        decidim_routes = Decidim::Core::Engine.routes.url_helpers
        return decidim_routes.new_user_session_path unless user_signed_in?

        participants = users.to_a.prepend(current_user)
        conversation = conversation_between_multiple(participants)

        if conversation
          decidim_routes.conversation_path(conversation)
        else
          decidim_routes.new_conversation_path(recipient_id: users.pluck(:id))
        end
      end

      #
      # Finds the conversation between the given participants
      #
      # @param participants [Array<Decidim::User>] The participants to find a
      #   conversation between.
      #
      # @return [Decidim::Messaging::Conversation]
      def conversation_between_multiple(participants)
        return if participants.to_set.length <= 1

        UserConversations.for(participants.first).find do |conversation|
          conversation.participants.to_set == participants.to_set
        end
      end
    end
  end
end
