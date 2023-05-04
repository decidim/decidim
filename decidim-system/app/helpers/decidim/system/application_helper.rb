# frozen_string_literal: true

module Decidim
  module System
    # Custom helpers, scoped to the system panel.
    #
    module ApplicationHelper
      include Decidim::LocalizedLocalesHelper

      def title
        "Decidim"
      end

      def current_admin?(admin)
        current_admin == admin
      end
    end
  end
end
