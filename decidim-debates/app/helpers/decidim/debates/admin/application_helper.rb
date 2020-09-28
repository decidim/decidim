# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # Custom helpers, scoped to the debates admin engine.
      #
      module ApplicationHelper
        include Decidim::Admin::ResourceScopeHelper
      end
    end
  end
end
