# frozen_string_literal: true

module Decidim
  module Debates
    # This command is executed when the user creates a Debate from the public
    # views.
    class CreateDebate < Decidim::Commands::CreateResource
      fetch_form_attributes :category, :scope

      private

      def resource_class = Decidim::Debates::Debate

      def extra_params = { visibility: "public-only" }

      def create_resource
        with_events(with_transaction: true) do
          super
        end
      end

      def run_after_hooks
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
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite

        super.merge({
                      author: form.current_user,
                      decidim_user_group_id: form.user_group_id,
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
