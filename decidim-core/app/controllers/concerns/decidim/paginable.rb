# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to paginate resources
  module Paginable
    extend ActiveSupport::Concern

    OPTIONS = [20, 50, 100].freeze

    included do
      helper_method :per_page

      def paginate(resources)
        resources.page(params[:page]).per(per_page)
      end

      def per_page
        params[:per_page] || OPTIONS.first
      end
    end
  end
end
