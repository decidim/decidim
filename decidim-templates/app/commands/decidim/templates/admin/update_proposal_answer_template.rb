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
            field_values: { proposal_state_id: @form.proposal_state_id },
            target: :proposal_answer
          )

          @template.update!(templatable: identify_templateable_resource)

          broadcast(:ok, @template)
        end

        private

        def identify_templateable_resource
          return if @form.component_constraint.blank?

          Decidim::Component.for_organization(organization: current_organization).find_by(id: @form.component_constraint, manifest_name: "proposals")
        end

        def current_organization
          @form.current_organization
        end
      end
    end
  end
end
