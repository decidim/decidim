# frozen_string_literal: true

module Decidim
  # A command with all the business logic to unendorse a resource, both as a user or as a user_group.
  class UnendorseResource < Rectify::Command
    # Public: Initializes the command.
    #
    # resource     - A Decidim::Endorsable object.
    # current_user - The current user.
    # current_group- (optional) The current_group that is unendorsing the Resource.
    def initialize(resource, current_user, current_group = nil)
      @resource = resource
      @current_user = current_user
      @current_group = current_group
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the resource.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      destroy_resource_endorsement
      broadcast(:ok, @resource)
    end

    private

    def destroy_resource_endorsement
      query = @resource.endorsements.where(
        author: @current_user,
        decidim_user_group_id: @current_group&.id
      )
      query.destroy_all
    end
  end
end
