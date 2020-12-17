# frozen_string_literal: true

module Decidim
  module Admin
    class CreateImport < Rectify::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        raise "CALL"
      end
    end
  end
end
