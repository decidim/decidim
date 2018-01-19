# frozen_string_literal: true

module Decidim
  module ContentRenderers
    class BaseRenderer
      attr_reader :content

      def initialize(content)
        @content = content
      end

      # Replaces any placeholder in the content and return
      # the content ready to be rendered to the user.
      # For example in a mentions renderer this will replace
      # a token like @user:id with a link to the profile.
      #
      # Override this in your renderer class if needed
      def render
        content
      end
    end
  end
end
