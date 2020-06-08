# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class CreateTemplate < Rectify::Command
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

          if template.persisted?
            broadcast(:ok, template)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def template
          @template ||= Decidim.traceability.create(
            Template,
            form.current_user,
            organization: form.current_organization,
            name: form.name
          )
        end
      end
    end
  end
end
