# frozen_string_literal: true

module Decidim
  # A command with the business logic to invite an user to an organization.
  class InviteUserAgain < Decidim::Command
    # Public: Initializes the command.
    #
    # user         - The user that receives the invitation instructions.
    # instructions - The invitation instructions that is sent to the user.
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
