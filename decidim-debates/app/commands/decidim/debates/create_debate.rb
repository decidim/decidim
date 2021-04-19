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
          send_notification_to_author_followers
          send_notification_to_space_followers
        end

        follow_debate
        broadcast(:ok, debate)
      end

      private

      attr_reader :debate, :form

      def create_debate
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite
        params = {
          author: form.current_user,
          decidim_user_group_id: form.user_group_id,
          category: form.category,
          title: {
            I18n.locale => parsed_title
          },
          description: {
            I18n.locale => parsed_description
          },
          scope: form.scope,
          component: form.current_component
        }

        @debate = Decidim.traceability.create!(
          Debate,
          form.current_user,
          params,
          visibility: "public-only"
        )
      end

      def send_notification_to_author_followers
        Decidim::EventsManager.publish(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource: debate,
          followers: debate.author.followers,
          extra: {
            type: "user"
          }
        )
      end

      def send_notification_to_space_followers
        Decidim::EventsManager.publish(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource: debate,
          followers: debate.participatory_space.followers,
          extra: {
            type: "participatory_space"
          }
        )
      end

      def follow_debate
        follow_form = Decidim::FollowForm
                      .from_params(followable_gid: debate.to_signed_global_id.to_s)
                      .with_context(current_user: debate.author)
        Decidim::CreateFollow.call(follow_form, debate.author)
      end
    end
  end
end
