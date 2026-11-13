# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to paginate resources
  module Paginable
    extend ActiveSupport::Concern

    OPTIONS = [25, 50, 100].freeze

    included do
      helper_method :per_page, :page_offset
      helper Decidim::PaginateHelper

      protected

      def per_page
        return default_per_page unless OPTIONS.include?(default_per_page)

        if OPTIONS.include?(params[:per_page])
          params.expect(:per_page).to_i
        elsif params[:per_page]
          sorted = OPTIONS.sort
          params.expect(:per_page).to_i.clamp(sorted.first, sorted.last)
        else
          default_per_page
        end
      end

      def page_offset
        [params.fetch(:page, 0).to_i - 1, 0].max * per_page
      end

      private

      def default_per_page
        OPTIONS.first
      end

      def paginate(resources)
        resources.page(params[:page]).per(per_page)
      end
    end
  end
end
