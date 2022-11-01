# frozen_string_literal: true

module Decidim
  module Tags
    module HiddenFieldExtensions
      def render
        @options.delete(:autocomplete)
        super
      end
    end
  end
end
