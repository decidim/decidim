# frozen_string_literal: true

module Decidim
  class ValidateUpload < Rectify::Command
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid, @form.errors) if @form.invalid?

      broadcast(:ok)
    end
  end
end
