# frozen_string_literal: true

module Decidim
  # A command with all the business logic to demote an admin. This means
  # removing their admin righta dn converting them to a basic member. It's the
  # coutnerpart of `PromoteMembership`.
  class DemoteMembership < Rectify::Command
    # Public: Initializes the command.
    #
    # membership - the UserGroupMembership to be demoted.
    def initialize(membership, user_group)
      @membership = membership
      @user_group = user_group
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if membership.blank?
      return broadcast(:invalid) if membership.role != "admin"
      return broadcast(:invalid) if membership.user_group != user_group

      transaction do
        demote_membership
        send_notification
      end

      broadcast(:ok)
    end

    private

    attr_reader :membership, :user_group

    def demote_membership
      membership.role = :member
      membership.save!
    end

    def send_notification
      Decidim::EventsManager.publish(
        event: "decidim.events.groups.demoted_membership",
        event_class: DemotedMembershipEvent,
        resource: membership.user_group,
        affected_users: [membership.user],
        extra: {
          user_group_name: membership.user_group.name,
          user_group_nickname: membership.user_group.nickname
        }
      )
    end
  end
end
