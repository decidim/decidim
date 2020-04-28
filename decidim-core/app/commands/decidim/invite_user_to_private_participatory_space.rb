# frozen_string_literal: true

module Decidim
  # A command with the business logic to invite a user to
  # a private participatory space.
  class InviteUserToPrivateParticipatorySpace < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(user, instructions)
      @user = user
      @instructions = instructions
    end

    def call
      user.invite!(user.invited_by, invitation_instructions: instructions)
      broadcast(:ok)
    end

    private

    attr_reader :user, :instructions
  end
end
