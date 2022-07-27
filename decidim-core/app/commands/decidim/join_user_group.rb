# frozen_string_literal: true

module Decidim
  # A command with all the business logic to join a user group.
  class JoinUserGroup < Decidim::Command
    # Public: Initializes the command.
    #
    # user - the user that wants to join the group
    # user_group - The user group to join
    def initialize(user, user_group)
      @user = user
      @user_group = user_group
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if already_member?

      transaction do
        join_user_group
        send_notification
      end

      broadcast(:ok, @user_group)
    end

    private

    attr_reader :user, :user_group

    def join_user_group
      Decidim::UserGroupMembership.create!(user:, user_group:, role: :requested)
    end

    def already_member?
      Decidim::UserGroupMembership.where(user:, user_group:).any?
    end

    def send_notification
      Decidim::EventsManager.publish(
        event: "decidim.events.groups.join_request_created",
        event_class: JoinRequestCreatedEvent,
        resource: user_group,
        affected_users: user_group.managers,
        extra: {
          user_group_name: user_group.name,
          user_group_nickname: user_group.nickname
        }
      )
    end
  end
end
