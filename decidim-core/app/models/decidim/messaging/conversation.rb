# frozen_string_literal: true

module Decidim
  module Messaging
    #
    # Holds a conversation between a number of participants. Each conversation
    # would be equivalent to an entry in your Telegram conversation list, be it
    # a group or a one-to-one conversation.
    #
    class Conversation < ApplicationRecord
      self.table_name = "decidim_messaging_conversations"

      include Decidim::DownloadYourData

      has_many :participations, foreign_key: :decidim_conversation_id,
                                class_name: "Decidim::Messaging::Participation",
                                dependent: :destroy,
                                inverse_of: :conversation

      has_many :participants, through: :participations

      has_many :messages, foreign_key: :decidim_conversation_id,
                          class_name: "Decidim::Messaging::Message",
                          dependent: :destroy,
                          inverse_of: :conversation

      has_many :receipts, through: :messages

      scope :unread_messages_by, lambda { |user|
        joins(:receipts).merge(Receipt.unread_by(user))
      }

      scope :unread_by, lambda { |user|
        unread_messages_by(user).distinct
      }

      default_scope { order(updated_at: :desc) }

      delegate :mark_as_read, to: :receipts

      #
      # Initiates a conversation between a user and a set of interlocutors with
      # an initial message. Works just like .start, but saves all the dependent
      # objects into DB.
      #
      # @param (see .start)
      #
      # @return (see .start)
      #
      def self.start!(originator:, interlocutors:, body:, user: nil)
        conversation = start(
          originator: originator,
          interlocutors: interlocutors,
          body: body,
          user: user
        )

        conversation.save!

        conversation
      end

      #
      # Initiates a conversation between a user and a set of interlocutors with
      # an initial message.
      #
      # @param originator [Decidim::UserBaseEntity] The user or group starting the conversation
      # @param interlocutors [Array<Decidim::User>] The set of interlocutors in
      #   the conversation (not including the originator).
      # @param body [String] The content of the initial message
      # @param user [Decidim::User] The user starting the conversation in case originator is a group
      #
      # @return [Decidim::Messaging::Conversation] The newly created conversation
      #
      def self.start(originator:, interlocutors:, body:, user: nil)
        conversation = new(participants: [originator] + interlocutors)

        conversation.add_message(sender: originator, body: body, user: user)

        conversation
      end

      # Appends a message to this conversation and saves everything to DB.
      #
      # @param (see #add_message)
      #
      # @return (see #add_message)
      #
      def add_message!(sender:, body:, user: nil)
        add_message(sender: sender, body: body, user: user)

        save!
      end

      #
      # Appends a message to this conversation
      #
      # @param sender [Decidim::UserBaseEntity] The sender of the message
      # @param body [String] The content of the message
      # @param user [Decidim::User] The user sending the message in case sender is a group
      #
      # @return [Decidim::Messaging::Message] The newly created message
      #
      def add_message(sender:, body:, user: nil)
        message = messages.build(sender: sender, body: body)

        message.envelope_for(recipients: interlocutors(sender), from: user)

        message
      end

      #
      # Given a user, returns their interlocutors in this conversation
      #
      # @param user [Decidim::User] The user to find interlocutors for
      #
      # @return [Array<Decidim::User>]
      #
      def interlocutors(user)
        participants.reject { |participant| participant.id == user.id }
      end

      #
      # Given a user, returns if ALL the interlocutors allow the user to join the conversation
      #
      # @return Boolean
      #
      def accept_user?(user)
        # if user is a group, members are accepted
        blocked = interlocutors(user).detect { |participant| !participant.accepts_conversation?(user) }
        blocked.blank?
      end

      #
      # Given a user, returns if ALL the interlocutors have their accounts deleted
      #
      # @return Boolean
      #
      def with_deleted_users?(user)
        interlocutors(user).all?(&:deleted?)
      end

      #
      # Given a user, returns if the user is participating in the conversation
      # for groups being part of a conversation all their admin member are accepted
      #
      # @return Boolean
      #
      def participating?(user)
        participants.include?(user)
      end

      #
      # The most recent message in this conversation
      #
      # @return [Decidim::Messaging::Message]
      #
      def last_message
        messages.last
      end

      #
      # The number of messages in this conversation a user has not yet read
      #
      # @return [Integer]
      #
      def unread_count(user)
        receipts.unread_by(user).count
      end

      def self.user_collection(user)
        Decidim::Messaging::UserConversations.for(user)
      end

      def self.export_serializer
        Decidim::DownloadYourDataSerializers::DownloadYourDataConversationSerializer
      end
    end
  end
end
