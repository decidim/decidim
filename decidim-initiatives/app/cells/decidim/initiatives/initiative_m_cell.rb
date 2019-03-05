# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the Medium (:m) initiative card
    # for an given instance of an Initiative
    class InitiativeMCell < Decidim::CardMCell
      include Decidim::Initiatives::Engine.routes.url_helpers

      property :state

      private

      def has_state?
        true
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
