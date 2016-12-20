module Decidim
  # A command with the business logic to invite an user to an organization.
  class RemoveUserRole < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(user, role)
      @user = user
      @role = role
    end

    def call
      return broadcast(:invalid) unless user

      user.roles.delete(role.to_s)
      user.save!

      broadcast(:ok)
    end

    private

    attr_reader :user, :role
  end
end
