# frozen_string_literal: true

module Decidim
  module Messaging
    module ConversationHelper
      # deprecated
      def conversation_name_for(users)
        return content_tag(:span, t("decidim.profile.deleted"), class: "label label--small label--basic") if users.first.deleted?

        content_tag = content_tag(:strong, users.first.name)
        content_tag << tag.br
        content_tag << content_tag(:span, "@#{users.first.nickname}", class: "muted")
        content_tag
      end

      def conversation_label_for(participants)
        return t("title", scope: "decidim.messaging.conversations.show", usernames: username_list(participants)) unless participants.count == 1

        chat_with_user = if participants.first.deleted?
                           t("decidim.profile.deleted")
                         else
                           "#{participants.first.name} (@#{participants.first.nickname})"
                         end

        "#{t("chat_with", scope: "decidim.messaging.conversations.show")} #{chat_with_user}"
      end

      #
      # Generates a visualization of users for listing conversations threads
      #
      def username_list(users, shorten: false)
        first_users = shorten ? users.first(3) : users
        content_tags = first_users.map do |u|
          u.deleted? ? t("decidim.profile.deleted") : u.name
        end

        return content_tags.join(", ") unless shorten
        return content_tags.join(", ") unless users.count > 3

        content_tags.push(" + #{users.count - 3}")
        content_tags.join(", ")
      end

      #
      # Links to the conversation between the current user and another user
      #
      def link_to_current_or_new_conversation_with(user, title = t("decidim.contact"))
        conversation_path = current_or_new_conversation_path_with(user)
        if conversation_path
          link_to(conversation_path, title:) do
            icon "mail-send-line", aria_label: title, class: "icon--small"
          end
        else
          content_tag :span, title: t("decidim.user_contact_disabled"), data: { tooltip: true } do
            icon "mail-send-line", aria_label: title, class: "icon--small muted"
          end
        end
      end

      #
      # Same as #link_to_current_or_new_conversation_with, but with a text body instead of an icon
      #
      # Links to the conversation between the current user and another user
      #
      # deprecated ?
      def text_link_to_current_or_new_conversation_with(user, body = t("decidim.profiles.show.send_private_message"))
        conversation_path = current_or_new_conversation_path_with(user)
        link_to body, conversation_path, title: body if conversation_path
      end

      #
      # Finds the right path to the conversation the current user and another
      # user (the interlocutor).
      #
      # * If there is no current user, it returns to the login form path.
      #
      # * If there is a prior existing conversation between the users it returns
      #   the path to the existing conversation.
      #
      # * If there is no prior conversation between the users, it checks if the
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
      # Links to the conversation between the current user and another users
      #
      def current_or_new_conversation_path_with_multiple(users, opts = {})
        return decidim_routes.new_user_session_path unless user_signed_in?

        active_participant = opts[:nickname].present? ? Decidim::UserBaseEntity.find_by(nickname: opts[:nickname]) : current_user
        participants = users.to_a.prepend(active_participant)
        conversation = conversation_between_multiple(participants)

        if opts[:nickname].present?
          current_or_new_profile_conversation_path(opts[:nickname], users, conversation)
        else
          current_or_new_user_conversation_path(users, conversation)
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

      def current_or_new_profile_conversation_path(nickname, users, conversation = nil)
        return decidim_routes.profile_conversation_path(conversation, nickname:) if conversation.present?

        decidim_routes.new_profile_conversation_path(nickname:, recipient_id: users.pluck(:id))
      end

      def current_or_new_user_conversation_path(users, conversation = nil)
        return decidim_routes.conversation_path(conversation) if conversation.present?

        decidim_routes.new_conversation_path(recipient_id: users.pluck(:id))
      end

      private

      def decidim_routes
        @decidim_routes ||= Decidim::Core::Engine.routes.url_helpers
      end
    end
  end
end
