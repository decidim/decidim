# frozen_string_literal: true

module Decidim
  # A command with all the business logic to leave a user group.
  class LeaveUserGroup < Rectify::Command
    # Public: Initializes the command.
    #
    # user - the user that wants to leave the group
    # user_group - The user group to leave
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
      return broadcast(:invalid) unless can_leave?

      leave_user_group

      broadcast(:ok, @user_group)
    end

    private

    attr_reader :user, :user_group

    def leave_user_group
      Decidim::UserGroupMembership.find_by!(user: user, user_group: user_group).destroy!
    end

    def can_leave?
      Decidim::UserGroupMembership.where(user: user, user_group: user_group).where.not(role: :creator).any?
    end
  end
end
