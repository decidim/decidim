# frozen_string_literal: true

module Decidim
  module Admin
    class CreateImportExample < Decidim::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        broadcast(:ok, form.example)
      end

      private

      attr_reader :form
    end
  end
end
