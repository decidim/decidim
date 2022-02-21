# frozen_string_literal: true

module Decidim
  #
  # Decorator to format validation errors of a form in html format
  #
  class ValidationErrorsPresenter < SimpleDelegator
    include Decidim::SanitizeHelper

    attr_reader :error, :form

    def initialize(error, form)
      @error = error
      @form = form
    end

    def message
      "<p>#{error}</p>#{validation_errors_list}"
    end

    def validation_errors_list
      return "" if form.valid?

      content_tag(:ul, decidim_sanitize(form.errors.full_messages.map { |err| content_tag(:li, err) }.join))
    end
  end
end
