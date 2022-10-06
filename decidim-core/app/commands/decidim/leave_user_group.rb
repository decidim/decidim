# frozen_string_literal: true

module Decidim
  # A command with all the business logic to leave a user group.
  class LeaveUserGroup < Decidim::Command
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
      return broadcast(:last_admin) if last_admin?

      leave_user_group

      broadcast(:ok, @user_group)
    end

    private

    attr_reader :user, :user_group

    def leave_user_group
      Decidim::UserGroupMembership.find_by!(user:, user_group:).destroy!
    end

    def can_leave?
      Decidim::UserGroupMembership.where(user:, user_group:).any?
    end

    def last_admin?
      admin_memberships = Decidim::UserGroupMembership.where(user_group:, role: [:creator, :admin])
      admin_memberships.length == 1 && admin_memberships.pluck(:decidim_user_id).include?(user.id)
    end
  end
end
