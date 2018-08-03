# frozen_string_literal: true

module Decidim
  # A command with all the business logic when a user starts amending a resource.
  class CreateAmend < Rectify::Command
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

    attr_reader :amendment, :form, :current_user

    def create_emendation!
      @emendation = Decidim.traceability.create!(
        form.amendable_type.constantize,
        form.current_user,
        emendation_attributes
      )
      @emendation.add_coauthor(form.current_user, user_group: nil)
    end

    def emendation_attributes
      {
        title: "[emendation] #{form.title}",
        body: form.body,
        component: form.amendable.component,
        published_at: Time.current
        # category: form.category,
        # scope: form.scope,
        # address: form.address,
        # latitude: form.latitude,
        # longitude: form.longitude,
      }
    end

    def create_amend!
      @amendment = Decidim::Amendment.create!(
        amender: form.current_user,
        amendable: form.amendable,
        emendation: @emendation,
        decidim_emendation_type: form.emendation_type,
        state: "evaluating"
      )
    end

    def notify_amendable_authors_and_followers
      return # not implemented - to do!
      recipients = amendable.authors + amendable.followers
      Decidim::EventsManager.publish(
        event: "decidim.events.amends.amendment_created",
        event_class: Decidim::AmendmentCreatedEvent,
        resource: @form.amendable,
        recipient_ids: recipients.pluck(:id)
      )
    end
  end
end
