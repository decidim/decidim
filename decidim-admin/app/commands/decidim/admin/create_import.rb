# frozen_string_literal: true

module Decidim
  module Admin
    class CreateImport < Decidim::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        imported_data = form.importer.prepare
        transaction do
          form.importer.import!

          broadcast(:ok, imported_data)
        rescue StandardError
          # Something went wrong with import/finish
          broadcast(:invalid)
          raise ActiveRecord::Rollback
        end
      end

      attr_reader :form
    end
  end
end
