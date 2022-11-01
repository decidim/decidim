# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class CreateTemplate < Decidim::Command
        # Initializes the command.
        #
        # form - The source for this QuestionnaireTemplate.
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) unless @form.valid?

          @template = Decidim.traceability.create!(
            Template,
            @form.current_user,
            name: @form.name,
            description: @form.description,
            organization: @form.current_organization,
            field_values:,
            target:
          )

          assign_template!

          broadcast(:ok, @template)
        end

        protected

        def assign_template!
          @template.update!(templatable: @form.current_organization)
        end

        def field_values
          {}
        end

        def target
          raise "Not implemented"
        end
      end
    end
  end
end
