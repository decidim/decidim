# frozen_string_literal: true

module Decidim
  # It represents a speaker of the conference
  # Can be linked to an existent user in the platform
  class ConferenceSpeaker < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::TranslatableResource

    translatable_fields :position, :affiliation, :short_bio

    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User", optional: true
    belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference"
    has_many :conference_speaker_conference_meetings, dependent: :destroy
    has_many :conference_meetings, through: :conference_speaker_conference_meetings, foreign_key: "conference_speaker_id", class_name: "Decidim::ConferenceMeeting"

    validates :avatar, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_avatar_size } }

    default_scope { order(full_name: :asc, created_at: :asc) }

    mount_uploader :avatar, Decidim::AvatarUploader

    delegate :organization, to: :conference

    alias participatory_space conference
    alias meetings conference_meetings

    def self.log_presenter_class_for(_log)
      Decidim::Conferences::AdminLog::ConferenceSpeakerPresenter
    end

    def twitter_handle
      attributes["twitter_handle"].to_s.delete("@")
    end
  end
end
