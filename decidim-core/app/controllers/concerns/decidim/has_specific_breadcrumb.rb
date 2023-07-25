# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasSpecificBreadcrumb
    extend ActiveSupport::Concern

    included do
      before_action :set_breadcrumb_item

      private

      def breadcrumb_item
        raise NotImplementedError, "Breadcrumb item needs definition"
      end

      def set_breadcrumb_item
        @context_breadcrumb_items ||= breadcrumb_item.is_a?(Array) ? breadcrumb_item : [breadcrumb_item]
      end
    end
  end
end
