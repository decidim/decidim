# frozen_string_literal: true

module Decidim
  # A command with the business logic to invite an user to an organization.
  class InviteUserAgain < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(user, instructions)
      @user = user
      @instructions = instructions
    end

    def call
      # This return is the one that prevents the user to be invited to a private
      # participatory space if they signed up by themselves instead of by an invitation.
      # return broadcast(:invalid) unless user&.invited_to_sign_up?

      user.invite!(user.invited_by, invitation_instructions: instructions)

      broadcast(:ok)
    end

    private

    attr_reader :user, :instructions
  end
end
