# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user creates a Meeting from the admin
      # panel.
      class CreateMeeting < Decidim::Command
        def initialize(form)
          @form = form
        end

        # Creates the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_meeting!
            create_services!
          end

          create_follow_form_resource(form.current_user)
          broadcast(:ok, meeting)
        end

        private

        attr_reader :form, :meeting

        def create_meeting!
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse(form.description, current_organization: form.current_organization).rewrite
          params = {
            scope: form.scope,
            category: form.category,
            title: parsed_title,
            description: parsed_description,
            end_time: form.end_time,
            start_time: form.start_time,
            online_meeting_url: form.online_meeting_url,
            registration_type: form.registration_type,
            registration_url: form.registration_url,
            type_of_meeting: form.clean_type_of_meeting,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            location: form.location,
            location_hints: form.location_hints,
            private_meeting: form.private_meeting,
            transparent: form.transparent,
            author: form.current_organization,
            registration_terms: form.current_component.settings.default_registration_terms,
            component: form.current_component,
            questionnaire: Decidim::Forms::Questionnaire.new,
            iframe_embed_type: form.iframe_embed_type,
            comments_enabled: form.comments_enabled,
            comments_start_time: form.comments_start_time,
            comments_end_time: form.comments_end_time,
            iframe_access_level: form.iframe_access_level
          }

          @meeting = Decidim.traceability.create!(
            Meeting,
            form.current_user,
            params,
            visibility: "all"
          )
        end

        def create_services!
          form.services_to_persist.each do |service|
            Decidim::Meetings::Service.create!(
              meeting: meeting,
              "title" => service.title,
              "description" => service.description
            )
          end
        end

        def create_follow_form_resource(user)
          follow_form = Decidim::FollowForm.from_params(followable_gid: meeting.to_signed_global_id.to_s).with_context(current_user: user)
          Decidim::CreateFollow.call(follow_form, user)
        end
      end
    end
  end
end
