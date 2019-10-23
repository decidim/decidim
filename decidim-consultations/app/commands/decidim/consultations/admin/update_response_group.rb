# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic when updating a new response group
      class UpdateResponseGroup < Rectify::Command
        # Public: Initializes the command.
        #
        # response_group - the response group to update
        # form - A form object with the params.
        def initialize(response_group, form)
          @response_group = response_group
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

          broadcast(:ok, update_response_group)
        end

        private

        attr_reader :form, :response_group

        def update_response_group
          response_group.assign_attributes(attributes)
          response_group.save!
        end

        def attributes
          {
            title: form.title
          }
        end
      end
    end
  end
end
