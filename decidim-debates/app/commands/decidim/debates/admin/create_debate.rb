# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This command is executed when the user creates a Debate from the admin
      # panel.
      class CreateDebate < Decidim::Commands::CreateResource
        include ::Decidim::MultipleAttachmentsMethods

        fetch_form_attributes :taxonomizations, :component, :information_updates, :instructions, :start_time, :end_time, :comments_enabled

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

        protected

        def resource_class = Decidim::Debates::Debate

        def extra_params = { visibility: "all" }

        def attributes
          parsed_title = Decidim::ContentProcessor.parse(form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:inline_images, debate.description, current_organization: debate.organization).rewrite
          super.merge({
                        author: form.current_organization,
                        title: parsed_title,
                        description: parsed_description,
                        end_time: (form.end_time if form.finite),
                        start_time: (form.start_time if form.finite),
                        comments_layout: form.comments_layout
                      })
        end

        def run_after_hooks
          @attached_to = resource
          create_attachments(first_weight: 1) if process_attachments?

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
