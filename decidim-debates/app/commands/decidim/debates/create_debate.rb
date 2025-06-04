# frozen_string_literal: true

module Decidim
  module Debates
    # This command is executed when the user creates a Debate from the public
    # views.
    class CreateDebate < Decidim::Commands::CreateResource
      include ::Decidim::MultipleAttachmentsMethods

      fetch_form_attributes :taxonomizations

      def call
        return broadcast(:invalid) if invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        perform!
        broadcast(:ok, resource)
      rescue ActiveRecord::RecordInvalid
        add_file_attribute_errors!
        broadcast(:invalid)
      rescue Decidim::Commands::HookError
        broadcast(:invalid)
      end

      private

      def resource_class = Decidim::Debates::Debate

      def extra_params = { visibility: "public-only" }

      def create_resource
        with_events(with_transaction: true) do
          super
        end
      end

      def run_after_hooks
        @attached_to = resource
        create_attachments(first_weight: 1) if process_attachments?
        send_notification_to_author_followers
        send_notification_to_space_followers
        follow_debate
      end

      def event_arguments
        {
          resource:,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def attributes
        parsed_title = form.title
        parsed_description = form.description

        super.merge({
                      author: form.current_user,
                      title: { I18n.locale => parsed_title },
                      description: { I18n.locale => parsed_description },
                      component: form.current_component
                    })
      end

      def send_notification_to_author_followers
        Decidim::EventsManager.publish(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource:,
          followers: resource.author.followers,
          extra: {
            type: "user"
          }
        )
      end

      def send_notification_to_space_followers
        Decidim::EventsManager.publish(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource:,
          followers: resource.participatory_space.followers,
          extra: {
            type: "participatory_space"
          }
        )
      end

      def follow_debate
        follow_form = Decidim::FollowForm
                      .from_params(followable_gid: resource.to_signed_global_id.to_s)
                      .with_context(current_user: resource.author)
        Decidim::CreateFollow.call(follow_form)
      end
    end
  end
end
