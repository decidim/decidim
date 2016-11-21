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
    end
  end
end
