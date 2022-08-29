# frozen_string_literal: true

module Decidim
  # A command with all the business logic to invite a user to a group.
  class InviteUserToGroup < Decidim::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    # user_group - The user group that invites the user
    def initialize(form, user_group)
      @form = form
      @user_group = user_group
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?
      return broadcast(:ok) if user_belongs_to_group?

      transaction do
        invite_user
        send_notification
      end

      broadcast(:ok)
    end

    private

    attr_reader :form, :user_group

    def invite_user
      Decidim::UserGroupMembership.create!(
        user: form.user,
        user_group:,
        role: :invited
      )
    end

    def send_notification
      Decidim::EventsManager.publish(
        event: "decidim.events.groups.invited_to_group",
        event_class: InvitedToGroupEvent,
        resource: user_group,
        affected_users: [form.user],
        extra: {
          user_group_name: user_group.name,
          user_group_nickname: user_group.nickname
        }
      )
    end

    def user_belongs_to_group?
      Decidim::UserGroupMembership.where(user: form.user, user_group:).any?
    end
  end
end
