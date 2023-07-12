# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to create conference members from the admin dashboard.
      class ConferenceSpeakerForm < Form
        include TranslatableAttributes
        include Decidim::ApplicationHelper

        translatable_attribute :position, String
        translatable_attribute :affiliation, String
        translatable_attribute :short_bio, String

        mimic :conference_speaker

        attribute :full_name, String
        attribute :twitter_handle, String
        attribute :personal_url, String
        attribute :avatar, Decidim::Attributes::Blob
        attribute :remove_avatar, Boolean, default: false
        attribute :user_id, Integer
        attribute :existing_user, Boolean, default: false
        attribute :conference_meeting_ids, Array[Integer]

        validates :full_name, presence: true, unless: proc { |object| object.existing_user }
        validates :user, presence: true, if: proc { |object| object.existing_user }
        validates :position, :affiliation, presence: true
        validates :avatar, passthru: {
          to: Decidim::ConferenceSpeaker,
          with: {
            # The speaker gets its organization context through the conference
            # object which is why we need to create a dummy conference in order
            # to pass the correct organization context to the file upload
            # validators.
            conference: lambda do |form|
              Decidim::Conference.new(organization: form.current_organization)
            end
          }
        }
        validate :personal_url_format

        def personal_url
          return if super.blank?

          return "http://#{super}" unless super.match?(%r{\A(http|https)://}i)

          super
        end

        def map_model(model)
          self.user_id = model.decidim_user_id
          self.existing_user = user_id.present?
          self.conference_meeting_ids = model.conference_meetings.pluck(:conference_meeting_id)
        end

        def user
          @user ||= current_organization.users.find_by(id: user_id)
        end

        def conference_meetings
          meeting_components = current_participatory_space.components.where(manifest_name: "meetings")
          return unless meeting_components || conference_meeting_ids.delete("").present?

          @conference_meetings ||= Decidim::ConferenceMeeting.where(component: meeting_components).where(id: conference_meeting_ids)
        end

        def meetings
          meeting_components = current_participatory_space.components.where(manifest_name: "meetings")
          @meetings ||= Decidim::ConferenceMeeting.where(component: meeting_components)
                                                   &.order(title: :asc)
                                                   &.map { |meeting| [present(meeting).title, meeting.id] }
        end

        private

        def personal_url_format
          return if personal_url.blank?

          uri = URI.parse(personal_url)
          errors.add :personal_url, :invalid if !uri.is_a?(URI::HTTP) || uri.host.nil?
        rescue URI::InvalidURIError
          errors.add :personal_url, :invalid
        end
      end
    end
  end
end
