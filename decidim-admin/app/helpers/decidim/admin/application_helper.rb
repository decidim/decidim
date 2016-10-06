# frozen_string_literal: true
module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module ApplicationHelper
      def title
        request.env["decidim.current_organization"].name
      end
    end
  end
end
