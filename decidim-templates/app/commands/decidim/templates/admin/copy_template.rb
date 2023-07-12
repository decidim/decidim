# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class CopyTemplate < Decidim::Command
        def initialize(template, user)
          @template = template
          @user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @template.valid?

          Decidim.traceability.perform_action!("duplicate", @template, @user) do
            Template.transaction do
              copy_template
            end
          end

          broadcast(:ok, @copied_template)
        end

        def copy_template
          @copied_template = Template.create!(
            organization: @template.organization,
            name: @template.name,
            description: @template.description,
            target: @template.target,
            field_values: @template.field_values,
            templatable: @template.templatable
          )
        end
      end
    end
  end
end
