# frozen_string_literal: true

module Decidim
  # A command with all the business logic to join a user group.
  class JoinUserGroup < Rectify::Command
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

      join_user_group

      broadcast(:ok, @user_group)
    end

    private

    attr_reader :user, :user_group

    def join_user_group
      Decidim::UserGroupMembership.create!(user: user, user_group: user_group, role: :requested)
    end

    def already_member?
      Decidim::UserGroupMembership.where(user: user, user_group: user_group).any?
    end
  end
end
