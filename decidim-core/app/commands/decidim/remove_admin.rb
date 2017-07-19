# frozen_string_literal: true

module Decidim
  # A command to remove the admin privilege to an user.
  class RemoveAdmin < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(user)
      @user = user
    end

    def call
      return broadcast(:invalid) unless user

      user.update_attributes!(admin: false)

      broadcast(:ok)
    end

    private

    attr_reader :user
  end
end
