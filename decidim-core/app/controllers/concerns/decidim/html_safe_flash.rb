# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This module allows creating flash messages that are HTML safe by providing
  # the flash[:html_safe] key in the flash hash.
  #
  # @example Setting HTML safe flash in a controller
  #    class YourController
  #      include Decidim::HtmlSafeFlash
  #
  #      def create
  #        YourRecord.create!(record_params)
  #
  #        flash[:html_safe] = true
  #        flash[:success] = t(".record_created_html")
  #      end
  #    end
  module HtmlSafeFlash
    extend ActiveSupport::Concern

    included do
      before_action :handle_html_safe_flash
    end

    private

    def handle_html_safe_flash
      html_safe = flash[:html_safe]
      flash.delete(:html_safe)
      return unless html_safe

      flash.each do |key, value|
        flash[key] = value.html_safe
        flash.discard(key)
      end
    end
  end
end
