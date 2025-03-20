# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This command is executed when the user creates a Debate from the admin
      # panel.
      class CreateDebate < Decidim::Commands::CreateResource
        fetch_form_attributes :category, :component, :information_updates, :instructions, :scope, :start_time, :end_time, :comments_enabled

        protected

        def resource_class = Decidim::Debates::Debate

        def extra_params = { visibility: "all" }

        def attributes
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite
          super.merge({
                        author: form.current_organization,
                        title: parsed_title,
                        description: parsed_description,
                        end_time: (form.end_time if form.finite),
                        start_time: (form.start_time if form.finite)
                      })
        end

        def run_after_hooks
          Decidim::EventsManager.publish(
            event: "decidim.events.debates.debate_created",
            event_class: Decidim::Debates::CreateDebateEvent,
            resource:,
            followers: form.component.participatory_space.followers,
            extra: {
              type: "participatory_space"
            }
          )
        end
      end
    end
  end
end
