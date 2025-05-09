# frozen_string_literal: true

module Decidim
  # A command with all the business logic related with a user liking a resource.
  # This is a user creates and like.
  class LikeResource < Decidim::Command
    # Public: Initializes the command.
    #
    # resource     - An instance of Decidim::Likable.
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
      like = build_resource_like
      if like.save
        notify_liker_followers
        broadcast(:ok, like)
      else
        broadcast(:invalid)
      end
    rescue ActiveRecord::RecordNotUnique
      broadcast(:invalid)
    end

    private

    def build_resource_like
      @resource.likes.build(author: @current_user)
    end

    def notify_liker_followers
      Decidim::EventsManager.publish(
        event: "decidim.events.resource_liked",
        event_class: Decidim::ResourceLikedEvent,
        resource: @resource,
        followers: @current_user.followers,
        extra: {
          liker_id: @current_user.id
        }
      )
    end
  end
end
