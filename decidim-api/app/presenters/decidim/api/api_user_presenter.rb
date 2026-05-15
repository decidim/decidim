# frozen_string_literal: true

module Decidim
  module Api
    class ApiUserPresenter < Decidim::UserPresenter
      def deleted?
        false
      end

      def badge
        "verified-badge"
      end

      def can_be_contacted?
        false
      end

      def can_follow?
        false
      end
    end
  end
end
