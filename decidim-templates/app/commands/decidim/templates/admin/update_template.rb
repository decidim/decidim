# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class UpdateTemplate < Rectify::Command
        # Public: Initializes the command.
        #
        # template - the Template to update
        # form - A form object with the params.
        def initialize(template, form)
          @template = template
          @form = form
          @parent = Template.find_by(id: @template.parent)
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_template

          if @template.valid?
            broadcast(:ok, @template)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :template

        def update_template
          @template.assign_attributes(attributes)
          save_template if @template.valid?
        end

        def save_template
          transaction do
            @template.save!
            Decidim.traceability.perform_action!(:update, @template, form.current_user) do
              @template
            end
          end
        end

        def attributes
          {
            name: form.name
          }
        end
      end
    end
  end
end
