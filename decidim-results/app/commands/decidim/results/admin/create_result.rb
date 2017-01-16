# frozen_string_literal: true
module Decidim
  module Results
    module Admin
      # This command is executed when the user creates a Result from the admin
      # panel.
      class CreateResult < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the result if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          create_result
          broadcast(:ok)
        end

        private

        def create_result
          Result.create!(
            scope: @form.scope,
            category: @form.category,
            feature: @form.current_feature,
            title: @form.title,
            short_description: @form.short_description,
            description: @form.description
          )
        end
      end
    end
  end
end
