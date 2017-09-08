# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class Meeting < Meetings::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasAttachments
      include Decidim::HasFeature
      include Decidim::HasReference
      include Decidim::HasScope
      include Decidim::HasCategory
      include Decidim::Followable
      include Decidim::Comments::Commentable

      has_many :registrations, class_name: "Decidim::Meetings::Registration", foreign_key: "decidim_meeting_id"

      feature_manifest_name "meetings"

      validates :title, presence: true

      geocoded_by :address, http_headers: ->(proposal) { { "Referer" => proposal.feature.organization.host } }

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

      # Public: Overrides the `notifiable?` Notifiable concern method.
      def notifiable?(_context)
        true
      end

      # Public: Overrides the `users_to_notify` Notifiable concern method.
      def users_to_notify
        feature.participatory_space.admins
      end
    end
  end
end
