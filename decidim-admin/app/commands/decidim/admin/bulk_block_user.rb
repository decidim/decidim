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
          BlockUser.call(sub_form) do
            on(:ok) do
              result[:ok] << sub_form.user_id
            end
            on(:invalid) do
              result[:ko] << sub_form.user_id
            end
          end
        end
        broadcast(:ok, **result)
      end

      private

      attr_reader :form, :result
    end
  end
end
