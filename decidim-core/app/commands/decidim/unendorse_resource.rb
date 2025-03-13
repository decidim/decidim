# frozen_string_literal: true

module Decidim
  # A command with all the business logic to unendorse a resource.
  class UnendorseResource < Decidim::Command
    # Public: Initializes the command.
    #
    # resource     - A Decidim::Endorsable object.
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
      destroy_resource_endorsement
      broadcast(:ok, @resource)
    end

    private

    def destroy_resource_endorsement
      query = @resource.endorsements.where(author: @current_user)

      query.destroy_all
    end
  end
end
