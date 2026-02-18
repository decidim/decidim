# frozen_string_literal: true

module Decidim
  # A command with all the business logic to unlike a resource.
  class UnlikeResource < Decidim::Command
    # Public: Initializes the command.
    #
    # resource     - A Decidim::Likeable object.
    # current_user - The current user.
    def initialize(resource, current_user)
      @resource = resource
      @current_user = current_user
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the resource.
    # - :invalid if the form was not valid and we could not proceed.
    #
    # Returns nothing.
    def call
      destroy_resource_like
      broadcast(:ok, @resource)
    end

    private

    def destroy_resource_like
      query = @resource.likes.where(author: @current_user)

      query.destroy_all
    end
  end
end
