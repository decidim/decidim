# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user promotes a rejected emendation.
    class Promote < Rectify::Command
      # Public: Initializes the command.
      #
      # emendation - The emendation to promote.
      # amendable - The amendable resource.
      def initialize(form)
        @form = form
        @emendation = form.emendation
        @amendable = form.emendation.amendable
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the emendation is promoted.
      # - :invalid if the transaction fails
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.invalid?

        transaction do
          promote_emendation!
          notify_amendable_and_emendation_authors_and_followers
        end

        broadcast(:ok, @promoted_emendation)
      end

      private

      def promote_emendation!
        @promoted_emendation = Decidim.traceability.perform_action!(
          "promote",
          @form.amendable_type.constantize,
          @emendation.creator_author,
          visibility: "public-only",
          promoted_from: @emendation.id
        ) do
          promoted_emendation = @form.amendable_type.constantize.new(emendation_attributes)
          promoted_emendation.add_coauthor(@emendation.creator_author, user_group: nil) if promoted_emendation.is_a?(Decidim::Coauthorable)
          promoted_emendation.save!
          promoted_emendation
        end
      end

      def emendation_attributes
        fields = {}

        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, @emendation.title, current_organization: @form.current_organization).rewrite
        parsed_body = Decidim::ContentProcessor.parse_with_processor(:hashtag, @emendation.body, current_organization: @form.current_organization).rewrite

        fields[:title] = parsed_title
        fields[:body] = parsed_body
        fields[:component] = @emendation.component
        fields[:published_at] = Time.current if @form.emendation_type == "Decidim::Proposals::Proposal"

        fields
      end

      def notify_amendable_and_emendation_authors_and_followers
        affected_users = @emendation.authors + @amendable.authors
        followers = @emendation.followers + @amendable.followers - affected_users

        Decidim::EventsManager.publish(
          event: "decidim.events.amendments.amendment_promoted",
          event_class: Decidim::Amendable::EmendationPromotedEvent,
          resource: @emendation,
          affected_users: affected_users,
          followers: followers
        )
      end
    end
  end
end
