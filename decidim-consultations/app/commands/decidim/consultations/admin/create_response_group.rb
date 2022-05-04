# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic when creating a new response group
      class CreateResponseGroup < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          broadcast(:ok, create_response_group)
        end

        private

        attr_reader :form

        def create_response_group
          ResponseGroup.create(
            question: form.context.current_question,
            title: form.title
          )
        end
      end
    end
  end
end
