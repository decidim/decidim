# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class UpdateProposalAnswerTemplate < Decidim::Command
        # Initializes the command.
        #
        # template    - The Template to update.
        # form        - The form object containing the data to update.
        # user        - The user that updates the template.
        def initialize(template, form, user)
          @template = template
          @form = form
          @user = user
        end

        def call
          return broadcast(:invalid) unless @form.valid?
          return broadcast(:invalid) unless @user.organization == @template.organization

          @template = Decidim.traceability.update!(
            @template,
            @user,
            name: @form.name,
            description: @form.description,
            field_values: { internal_state: @form.internal_state },
            target: :proposal_answer
          )

          @template.update!(templatable: identify_templateable_resource)

          broadcast(:ok, @template)
        end

        private

        def identify_templateable_resource
          resource = @form.current_organization
          if @form.component_constraint.present?
            found_component = Decidim::Component.find_by(id: @form.component_constraint, manifest_name: "proposals")
            if found_component.present?
              resource = found_component&.participatory_space&.decidim_organization_id == @form.current_organization.id ? found_component : nil
            end
          end
          resource
        end
      end
    end
  end
end
