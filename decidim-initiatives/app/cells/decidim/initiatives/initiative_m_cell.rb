# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the Medium (:m) initiative card
    # for an given instance of an Initiative
    class InitiativeMCell < Decidim::CardMCell
      include Decidim::Initiatives::Engine.routes.url_helpers

      property :state

      private

      def title
        decidim_html_escape(translated_attribute(model.title))
      end

      def hashtag
        decidim_html_escape(model.hashtag)
      end

      def has_state?
        true
      end

      # Explicitely commenting the used I18n keys so their are not flagged as unused
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.accepted')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.created')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.discarded')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.published')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.rejected')
      # i18n-tasks-use t('decidim.initiatives.show.badge_name.validating')
      def badge_name
        I18n.t(model.state, scope: "decidim.initiatives.show.badge_name")
      end

      def state_classes
        case state
        when "accepted", "published"
          ["success"]
        when "rejected", "discarded"
          ["alert"]
        when "validating"
          ["warning"]
        else
          ["muted"]
        end
      end

      def resource_path
        initiative_path(model)
      end

      def resource_icon
        icon "initiatives", class: "icon--big"
      end

      def authors
        [present(model).author] +
          model.committee_members.approved.non_deleted.excluding_author.map { |member| present(member.user) }
      end
    end
  end
end
