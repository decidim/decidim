# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class LastActivityCell < Decidim::ViewModel
      include Decidim::CardHelper
      include Decidim::IconHelper

      delegate :current_organization, to: :controller

      def show
        return if last_activity.blank?
        render
      end

      def last_activity
        @last_activity ||= Decidim::ActionLog
                           .where(organization: current_organization)
                           .includes(:participatory_space, :user, :resource, :component, :version)
                           .public
                           .order(created_at: :desc)
                           .first(4)
      end
    end
  end
end
