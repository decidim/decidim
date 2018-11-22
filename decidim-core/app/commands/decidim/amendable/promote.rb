# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user promotes a rejected emendation.
    class Promote < Rectify::Command
      # Public: Initializes the command.
      #
      # collaborative_draft - The collaborative_draft to publish.
      # current_user - The current user.
      # proposal_form - the form object of the new proposal
      def initialize(form)
        @form = form
        @emendation = form.emendation
        @amendable = form.emendation.amendable
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the collaborative_draft is published.
      # - :invalid if the collaborative_draft's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.invalid?

        transaction do
          promote_emendation

          notify_amendable_and_emendation_authors_and_followers
        end

        broadcast(:ok, @promoted_emendation)
      end

      private

      attr_accessor :form

      def promote_emendation
        @promoted_emendation = Decidim.traceability.perform_action!(
          :create,
          form.amendable_type.constantize,
          form.current_user
        ) do
          promoted_emendation = form.amendable_type.constantize.new(emendation_attributes)
          promoted_emendation.add_coauthor(form.current_user, user_group: form.user_group) if promoted_emendation.is_a?(Decidim::Coauthorable)
          promoted_emendation.save!
          promoted_emendation
        end
      end

      def emendation_attributes
        fields = {}
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, @emendation.title, current_organization: form.current_organization).rewrite
        parsed_body = Decidim::ContentProcessor.parse_with_processor(:hashtag, @emendation.body, current_organization: form.current_organization).rewrite
        fields[:title] = parsed_title
        fields[:body] = parsed_body
        fields[:component] = form.emendation.component
        fields[:published_at] = Time.current if form.emendation_type == "Decidim::Proposals::Proposal"
        fields
      end

      def notify_amendable_and_emendation_authors_and_followers
        recipients = @emendation.authors + @emendation.followers
        recipients += @amendable.authors + @amendable.followers
        Decidim::EventsManager.publish(
          event: "decidim.events.amendments.amendment_promoted",
          event_class: Decidim::Amendable::EmendationPromotedEvent,
          resource: @emendation,
          recipient_ids: recipients.pluck(:id)
        )
      end
    end
  end
end
