# frozen_string_literal: true

module Decidim
  module Forms
    #
    # Decorator for response_options
    #
    class ResponseOptionPresenter < SimpleDelegator
      include Decidim::TranslationsHelper

      def translated_body
        @translated_body ||= translated_attribute body
      end

      def as_json(*_args)
        { id:, body: translated_body }
      end
    end
  end
end
