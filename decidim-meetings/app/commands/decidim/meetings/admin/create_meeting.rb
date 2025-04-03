# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user creates a Meeting from the admin
      # panel.
      class CreateMeeting < Decidim::Commands::CreateResource
        fetch_form_attributes :end_time, :start_time, :online_meeting_url, :registration_type,
                              :registration_url, :address, :latitude, :longitude, :location, :location_hints,
                              :private_meeting, :transparent, :registrations_enabled, :component, :iframe_embed_type,
                              :comments_enabled, :taxonomizations, :comments_start_time, :comments_end_time, :iframe_access_level,
                              :reminder_enabled

        protected

        def run_after_hooks
          create_services!
          create_follow_form_resource(form.current_user)
          link_components!
        end

        def attributes
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse(form.description, current_organization: form.current_organization).rewrite

          super.merge({
                        title: parsed_title,
                        description: parsed_description,
                        type_of_meeting: form.clean_type_of_meeting,
                        author: form.current_organization,
                        registration_terms: form.current_component.settings.default_registration_terms,
                        questionnaire: Decidim::Forms::Questionnaire.new,
                        send_reminders_before_hours: form.reminder_enabled ? form.send_reminders_before_hours : nil,
                        reminder_message_custom_content: form.reminder_enabled ? form.reminder_message_custom_content : ""
                      })
        end

        def resource_class = Decidim::Meetings::Meeting

        def extra_params = { visibility: "all" }

        private

        def create_services!
          form.services_to_persist.each do |service|
            Decidim::Meetings::Service.create!(
              meeting: resource,
              title: service.title,
              description: service.description
            )
          end
        end

        def link_components!
          resource.components = form.components
          resource.save!
        end

        def create_follow_form_resource(user)
          follow_form = Decidim::FollowForm.from_params(followable_gid: resource.to_signed_global_id.to_s).with_context(current_user: user)
          Decidim::CreateFollow.call(follow_form)
        end
      end
    end
  end
end
