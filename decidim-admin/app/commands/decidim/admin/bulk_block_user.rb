# frozen_string_literal: true

module Decidim
  module Admin
    class BulkBlockUser < Decidim::Command
      # Public: Initializes the command.

      def initialize(form)
        @form = form
        @result = { ok: [], ko: [] }
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid?

        form.forms.each do |sub_form|
          BlockUser.call(form) do
            on(:ok) do
              result[:ok] << sub_form
            end
            on(:invalid) do
              result[:ok] << sub_form
            end
          end
        end
        broadcast(:ok, **result)
      end

      private

      attr_reader :form
    end
  end
end
