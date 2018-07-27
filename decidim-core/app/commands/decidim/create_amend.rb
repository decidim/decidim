# frozen_string_literal: true

module Decidim
  # A command with all the business logic for when a user starts amending a resource.
  class CreateAmend < Rectify::Command
    # Public: Initializes the command.
    #
    # form         - A form object with the params.
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

        # link both resources
        link_amendable_with_emendation

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
        decidim_user_id: form.current_user.id,
        decidim_amendable_type: form.amendable_type,
        decidim_amendable_id: form.amendable.id,
        decidim_emendation_type: form.amendable_type,
        decidim_emendation_id: @emendation.id,
        state: "evaluating"
      )
    end

    def link_amendable_with_emendation
      # form.amendable.link_resources(@emendation, "emendation_from_amendable")
    end

    def notify_amendable_authors_and_followers
      return
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
