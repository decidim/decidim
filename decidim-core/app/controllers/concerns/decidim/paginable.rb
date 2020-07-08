# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to paginate resources
  module Paginable
    extend ActiveSupport::Concern

    OPTIONS = [20, 50, 100].freeze

    included do
      helper_method :per_page, :page_offset
      helper Decidim::PaginateHelper

      def paginate(resources)
        resources.page(params[:page]).per(per_page)
      end

      def per_page
        params[:per_page] || OPTIONS.first
      end

      def page_offset
        [params[:page].to_i - 1, 0].max * per_page
      end
    end
  end
end
