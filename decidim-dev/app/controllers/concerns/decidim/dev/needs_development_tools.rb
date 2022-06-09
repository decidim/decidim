# frozen_string_literal: true

module Decidim
  module Dev
    # This concern adds development tools, such as the accessibility checks
    # to the views where this is included for development purposes. This should
    # be only included in the development environment.
    module NeedsDevelopmentTools
      extend ActiveSupport::Concern

      included do
        before_action :apply_development_tools
      end

      private

      def apply_development_tools
        return unless respond_to?(:snippets)

        snippets.add(:head, helpers.stylesheet_pack_tag("decidim_dev"))
        snippets.add(:foot, helpers.javascript_pack_tag("decidim_dev", defer: false))
      end
    end
  end
end
