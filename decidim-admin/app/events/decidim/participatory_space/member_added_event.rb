# frozen_string_literal: true

module Decidim
  module ParticipatorySpace
    # i18n-tasks-use t('decidim.events.participatory_space.member_added.published.email_intro')
    # i18n-tasks-use t('decidim.events.participatory_space.member_added.published.email_outro')
    # i18n-tasks-use t('decidim.events.participatory_space.member_added.published.email_subject')
    # i18n-tasks-use t('decidim.events.participatory_space.member_added.published.notification_title')
    # i18n-tasks-use t('decidim.events.participatory_space.member_added.unpublished.email_intro')
    # i18n-tasks-use t('decidim.events.participatory_space.member_added.unpublished.email_outro')
    # i18n-tasks-use t('decidim.events.participatory_space.member_added.unpublished.email_subject')
    # i18n-tasks-use t('decidim.events.participatory_space.member_added.unpublished.notification_title')
    class MemberAddedEvent < Decidim::Events::SimpleEvent
      include Rails.application.routes.mounted_helpers

      def i18n_scope
        return "#{super}.published" if membership&.published?

        "#{super}.unpublished"
      end

      def default_i18n_options
        super.merge(members_page:)
      end

      private

      def membership
        @membership ||= Decidim::ParticipatorySpace::Member.where(participatory_space:, user:).first
      end

      def members_page
        raise "#{__method__} needs to be implemented in the event class"
      end
    end
  end
end
