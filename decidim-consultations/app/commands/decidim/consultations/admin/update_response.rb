# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic when updating an response in the system.
      class UpdateResponse < Rectify::Command
        # Public: Initializes the command.
        #
        # response - the response to update
        # form - A form object with the params.
        def initialize(response, form)
          @response = response
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

          update_response
          broadcast(:ok, response)
        end

        private

        attr_reader :form, :response

        def update_response
          response.assign_attributes(attributes)
          response.save!
        end

        def attributes
          {
            title: form.title,
            response_group: form.response_group
          }
        end
      end
    end
  end
end
