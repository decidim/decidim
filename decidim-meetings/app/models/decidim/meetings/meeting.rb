# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class Meeting < Meetings::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::HasFeature
      include Decidim::HasReference
      include Decidim::ScopableFeature
      include Decidim::HasCategory
      include Decidim::Followable
      include Decidim::Comments::Commentable
      include Decidim::Searchable
      include Decidim::Traceable
      include Decidim::Loggable

      has_many :registrations, class_name: "Decidim::Meetings::Registration", foreign_key: "decidim_meeting_id", dependent: :destroy

      feature_manifest_name "meetings"

      validates :title, presence: true

      geocoded_by :address, http_headers: ->(proposal) { { "Referer" => proposal.feature.organization.host } }

      scope :past, -> { where(arel_table[:end_time].lteq(Time.current)) }
      scope :upcoming, -> { where(arel_table[:start_time].gt(Time.current)) }

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::MeetingPresenter
      end

      def closed?
        closed_at.present?
      end

      def has_available_slots?
        return true if available_slots.zero?
        available_slots > registrations.count
      end

      def remaining_slots
        available_slots - registrations.count
      end

      def has_registration_for?(user)
        registrations.where(user: user).any?
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        feature.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        commentable? && !feature.current_settings.comments_blocked
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Public: Override Commentable concern method `users_to_notify_on_comment_created`
      def users_to_notify_on_comment_created
        followers
      end

      # Public: As Searchable, does the mapping of fields to be indexed.
      #
      #
      def search_rsrc_indexable_fields
        org = feature.organization
        fields = {
          decidim_scope_id: decidim_scope_id,
          decidim_participatory_space_id: feature.participatory_space_id,
          decidim_participatory_space_type: feature.participatory_space_type,
          decidim_organization_id: org.id,
          i18n: {}
        }
        i18n = fields[:i18n]
        org.available_locales.each do |locale|
          i18n[locale] = { A: [title[locale]], D: [description[locale], address] }
        end
        fields
      end
    end
  end
end
