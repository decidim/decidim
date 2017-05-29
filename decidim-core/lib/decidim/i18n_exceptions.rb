# frozen_string_literal: true

unless Rails.env.production?
  module I18n
    class JustRaiseExceptionHandler < ExceptionHandler
      def call(exception, locale, key, options)
        if exception.is_a?(MissingTranslationData) || exception.is_a?(MissingTranslation)
          raise exception.to_exception
        end

        super
      end
    end
  end

  I18n.exception_handler = I18n::JustRaiseExceptionHandler.new
end
