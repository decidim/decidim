# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update pages.
    class StaticPageForm < Form
      include TranslatableAttributes

      attribute :slug, String
      translatable_attribute :title, String
      translatable_attribute :content, String
      attribute :changed_notably, Boolean
      attribute :show_in_footer, Boolean
      attribute :allow_public_access, Boolean
      attribute :weight, Integer
      attribute :topic_id, Integer

      mimic :static_page

      validates :slug, presence: true
      validates :title, :content, translatable_presence: true
      validates :slug, format: { with: %r{\A[a-zA-Z]+[a-zA-Z0-9\-_/]+\z} }, allow_blank: true

      validate :slug, :slug_uniqueness

      alias organization current_organization

      def slug
        super.to_s.downcase
      end

      def topic
        @topic ||= StaticPageTopic.find_by(
          organization:,
          id: topic_id
        )
      end

      def topics
        @topics ||= StaticPageTopic.where(
          organization: current_organization
        )
      end

      def control_public_access?
        current_organization.force_users_to_authenticate_before_access_organization?
      end

      private

      def slug_uniqueness
        return unless organization
        return unless organization.static_pages.where(slug:).where.not(id:).any?

        errors.add(:slug, :taken)
      end
    end
  end
end
