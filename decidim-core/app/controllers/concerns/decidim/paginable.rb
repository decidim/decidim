# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to paginate resources
  module Paginable
    extend ActiveSupport::Concern

    OPTIONS = [10, 20, 50, 100].freeze

    included do
      helper_method :per_page, :page_offset
      helper Decidim::PaginateHelper

      def paginate(resources)
        resources.page(params[:page]).per(per_page)
      end

      def per_page
        if OPTIONS.include?(params[:per_page])
          params[:per_page]
        elsif params[:per_page]
          sorted = OPTIONS.sort
          params[:per_page].to_i.clamp(sorted.first, sorted.last)
        else
          OPTIONS.first
        end
      end

      def page_offset
        [params[:page].to_i - 1, 0].max * per_page
      end
    end
  end
end
