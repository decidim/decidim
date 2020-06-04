# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class CopyTemplate < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # template - An template we want to duplicate
        def initialize(form, template)
          @form = form
          @template = template
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          Template.transaction do
            copy_template
          end

          broadcast(:ok, @copied_template)
        end

        private

        attr_reader :form

        def copy_template
          @copied_template = Template.create!(
            attr: @template.attr
          )
        end
      end
    end
  end
end
