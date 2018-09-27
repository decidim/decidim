# frozen_string_literal: true

module Decidim
  module Debates
    # This command is executed when the user creates a Debate from the public
    # views.
    class CreateDebate < Rectify::Command
      def initialize(form)
        @form = form
      end

      # Creates the debate if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_debate
          send_notifications
        end
        broadcast(:ok, debate)
      end

      private

      attr_reader :debate, :form

      def organization
        @organization = form.current_component.organization
      end

      def i18n_field(field)
        organization.available_locales.inject({}) do |i18n, locale|
          i18n.update(locale => field)
        end
      end

      def create_debate
        params = {
          author: form.current_user,
          decidim_user_group_id: form.user_group_id,
          category: form.category,
          title: i18n_field(form.title),
          description: i18n_field(form.description),
          component: form.current_component
        }

        @debate = Decidim.traceability.create!(
          Debate,
          form.current_user,
          params,
          visibility: "public-only"
        )
      end

      def send_notifications
        send_notification(debate.author.followers.pluck(:id), :user)
        send_notification(debate.participatory_space.followers.pluck(:id), :participatory_space)
      end

      def send_notification(recipient_ids, type)
        Decidim::EventsManager.publish(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource: debate,
          recipient_ids: recipient_ids,
          extra: {
            type: type.to_s
          }
        )
      end
    end
  end
end
