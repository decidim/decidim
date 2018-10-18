# frozen_string_literal: true

module Decidim
  # A command with all the business logic to accept a join request to a user
  # group.
  class AcceptUserGroupJoinRequest < Rectify::Command
    # Public: Initializes the command.
    #
    # membership - the UserGroupMembership to be accepted.
    def initialize(membership)
      @membership = membership
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if membership.role.to_s != "requested"

      accept_membership

      broadcast(:ok, @user_group)
    end

    private

    attr_reader :membership

    def accept_membership
      membership.role = :member
      membership.save!
    end
  end
end
