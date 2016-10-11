# frozen_string_literal: true
module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module ApplicationHelper
      include Decidim::TranslationsHelper

      def title
        current_organization.name
      end
    end
  end
end
