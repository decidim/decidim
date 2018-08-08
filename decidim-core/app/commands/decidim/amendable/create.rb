# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user starts amending a resource.
    class Create < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # amendable    - The resource that is being amended.
      def initialize(form)
        @form = form
        @amendable = form.amendable
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the amend.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_emendation!
          create_amend!

          # The proposal authors and followers are notified that an amendment has been created.
          notify_amendable_authors_and_followers
        end

        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_emendation!
        @emendation = Decidim.traceability.create!(
          form.amendable_type.constantize,
          form.current_user,
          emendation_attributes
        )
        @emendation.add_coauthor(form.current_user, user_group: form.user_group)
      end

      def emendation_attributes
        {
          title: form.title,
          body: form.body,
          component: form.amendable.component,
          published_at: Time.current
        }
      end

      def create_amend!
        @amendment = Decidim::Amendment.create!(
          amender: form.current_user,
          amendable: form.amendable,
          emendation: @emendation,
          state: "evaluating"
        )
      end

      def notify_amendable_authors_and_followers
        # # not implemented - to do!
        # recipients = amendable.authors + amendable.followers
        # Decidim::EventsManager.publish(
        #   event: "decidim.events.amends.amendment_created",
        #   event_class: Decidim::AmendmentCreatedEvent,
        #   resource: @form.amendable,
        #   recipient_ids: recipients.pluck(:id)
        # )
      end
    end
  end
end
