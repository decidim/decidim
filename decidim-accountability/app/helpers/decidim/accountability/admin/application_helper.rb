# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # Custom helpers, scoped to the accountability admin engine.
      #
      module ApplicationHelper
        include Decidim::Admin::ResourceScopeHelper
      end
    end
  end
end
