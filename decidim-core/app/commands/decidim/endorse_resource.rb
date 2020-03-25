# frozen_string_literal: true

module Decidim
  # A command with all the business logic related with a user endorsing a resource.
  # This is a user creates and endorsement.
  class EndorseResource < Rectify::Command
    # Public: Initializes the command.
    #
    # resource     - An instance of Decidim::Endorsable.
    # current_user - The current user.
    # current_group_id- (optional) The current_grup that is endorsing the Resource.
    def initialize(resource, current_user, current_group_id = nil)
      @resource = resource
      @current_user = current_user
      @current_group_id = current_group_id
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the resource vote.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if existing_group_endorsement?

      endorsement = build_resource_endorsement
      if endorsement.save
        notify_endorser_followers
        broadcast(:ok, endorsement)
      else
        broadcast(:invalid)
      end
    end

    private

    def existing_group_endorsement?
      @current_group_id.present? && @resource.endorsements.exists?(decidim_user_group_id: @current_group_id)
    end

    def build_resource_endorsement
      endorsement = @resource.endorsements.build(author: @current_user)
      endorsement.user_group = user_groups.find(@current_group_id) if @current_group_id.present?
      endorsement
    end

    def user_groups
      Decidim::UserGroups::ManageableUserGroups.for(@current_user).verified
    end

    def notify_endorser_followers
      Decidim::EventsManager.publish(
        event: "decidim.events.resource_endorsed",
        event_class: Decidim::ResourceEndorsedEvent,
        resource: @resource,
        followers: @current_user.followers,
        extra: {
          endorser_id: @current_user.id
        }
      )
    end
  end
end
