# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This command is executed when the user creates a Debate from the admin
      # panel.
      class CreateDebate < Decidim::Command
        include ::Decidim::AttachmentMethods

        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) if form.invalid?

          if process_attachments?
            build_attachment
            return broadcast(:invalid) if attachment_invalid?
          end

          transaction do
            create_debate
            create_attachment(weight: first_attachment_weight) if process_attachments?
            send_notifications
          end

          broadcast(:ok, debate)
        end

        private

        attr_reader :form, :debate, :attachment

        def create_debate
          @debate = Decidim::Debates::Debate.create!(
            attributes.merge({
                               author: form.current_organization
                             })
          )
          @attached_to = debate
          Decidim.traceability.perform_action!(:publish, debate, form.current_user, visibility: "all")
        end

        def attributes
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite

          {
            title: parsed_title,
            description: parsed_description,
            category: form.category,
            scope: form.scope,
            component: form.component,
            start_time: form.start_time.presence,
            end_time: form.end_time.presence,
            information_updates: form.information_updates,
            instructions: form.instructions,
            comments_enabled: form.comments_enabled
          }
        end

        def send_notifications
          Decidim::EventsManager.publish(
            event: "decidim.events.debates.debate_created",
            event_class: Decidim::Debates::CreateDebateEvent,
            resource: debate,
            followers: form.component.participatory_space.followers,
            extra: {
              type: "participatory_space"
            }
          )
        end

        def first_attachment_weight
          debate.attachments.count.zero? ? 1 : debate.attachments.count + 1
        end
      end
    end
  end
end
