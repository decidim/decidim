# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module TranslatableResource
    extend ActiveSupport::Concern

    included do
      def self.translatable_fields(*list)
        @translatable_fields = list
      end

      def self.translatable_fields_list
        @translatable_fields
      end
    end
  end
end
