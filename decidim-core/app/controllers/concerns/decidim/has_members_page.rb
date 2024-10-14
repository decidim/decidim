# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasMembersPage
    extend ActiveSupport::Concern

    included do
      helper_method :collection

      private

      def can_visit_index?
        current_user_can_visit_space? && current_participatory_space.members_public_page?
      end

      def members
        @members ||= current_participatory_space.participatory_space_private_users.published
      end

      alias_method :collection, :members
    end
  end
end
