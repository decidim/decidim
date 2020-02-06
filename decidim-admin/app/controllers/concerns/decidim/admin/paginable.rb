# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    module Paginable
      # Common logic to paginate admin resources
      extend ActiveSupport::Concern

      included do
        include Decidim::Paginable

        def per_page
          params[:per_page].present? ? params[:per_page].to_i : Decidim::Admin.per_page_range.first
        end
      end
    end
  end
end
