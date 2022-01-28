# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user promotes a rejected emendation.
    class Promote < Decidim::Command
      # Public: Initializes the command.
      #
      # emendation - The emendation to promote.
      # amendable - The amendable resource.
      def initialize(form)
        @form = form
        @amendment = form.amendment
        @emendation = form.emendation
        @amendable = form.amendable
        @amender = form.amender
        @current_user = form.current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the emendation is promoted.
      # - :invalid if the transaction fails
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid? && amendment.rejected? && amender == current_user

        transaction do
          promote_emendation!
          notify_amendable_and_emendation_authors_and_followers
          link_promoted_emendation_and_proposal
        end

        broadcast(:ok, @promoted_emendation)
      end

      private

      attr_reader :form, :amendment, :amender, :current_user

      # The log of this action contains unique information:
      # extra_log_info = { promoted_from: emendation.id }
      def promote_emendation!
        @promoted_emendation = Decidim.traceability.perform_action!(
          "promote",
          @emendation.class,
          @emendation.creator_author,
          visibility: "public-only",
          promoted_from: @emendation.id
        ) do
          promoted_emendation = @emendation.class.new(form.emendation_params)
          promoted_emendation.component = @emendation.component
          promoted_emendation&.published_at = Time.current
          promoted_emendation.add_coauthor(@emendation.creator_author)
          promoted_emendation.save!
          promoted_emendation
        end
      end

      def notify_amendable_and_emendation_authors_and_followers
        affected_users = @emendation.authors + @amendable.notifiable_identities
        followers = @emendation.followers + @amendable.followers - affected_users

        Decidim::EventsManager.publish(
          event: "decidim.events.amendments.amendment_promoted",
          event_class: Decidim::Amendable::EmendationPromotedEvent,
          resource: @emendation,
          affected_users: affected_users.uniq,
          followers: followers.uniq
        )
      end

      def link_promoted_emendation_and_proposal
        @promoted_emendation.link_resources(@emendation, "created_from_rejected_emendation")
      end
    end
  end
end
