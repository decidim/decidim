# frozen_string_literal: true

module Decidim
  module RectifyCommand
    def method_missing(method_name, ...)
      if @caller.respond_to?(method_name, true)
        @caller.send(method_name, ...)
      else
        super
      end
    end
  end
end
