# frozen_string_literal: true

module Decidim
  module ScreenshotHelperExt
    def self.included(_base)
      require_relative "ext/screenshot_helper"
    end
  end
end
