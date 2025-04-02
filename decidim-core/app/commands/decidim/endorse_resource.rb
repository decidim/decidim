# frozen_string_literal: true

module Decidim
  # A command with all the business logic related with a user endorsing a resource.
  # This is a user creates and endorsement.
  class EndorseResource < Decidim::Command
    # Public: Initializes the command.
    #
    # resource     - An instance of Decidim::Endorsable.
    # current_user - The current user.
    def initialize(resource, current_user)
      @resource = resource
      @current_user = current_user
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the resource vote.
    # - :invalid if the form was not valid and we could not proceed.
    #
    # Returns nothing.
    def call
      endorsement = build_resource_endorsement
      if endorsement.save
        notify_endorser_followers
        broadcast(:ok, endorsement)
      else
        broadcast(:invalid)
      end
    rescue ActiveRecord::RecordNotUnique
      broadcast(:invalid)
    end

    private

    def build_resource_endorsement
      @resource.endorsements.build(author: @current_user)
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
