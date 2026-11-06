# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class CreateProposalAnswerTemplate < Decidim::Command
        # Initializes the command.
        #
        # form - The source for this ProposalAnswerTemplate.
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:component_selected) if @form.select_component
          return broadcast(:invalid) unless @form.valid?

          @template = Decidim.traceability.create!(
            Template,
            @form.current_user,
            name: @form.name,
            description: @form.description,
            organization: @form.current_organization,
            field_values: { proposal_state_id: @form.proposal_state_id },
            target: :proposal_answer
          )

          @template.update!(templatable: identify_templateable_resource)

          broadcast(:ok, @template)
        end

        private

        def identify_templateable_resource
          return current_organization if @form.component_constraint.blank?

          Decidim::Component.for_organization(organization: current_organization).find_by(id: @form.component_constraint, manifest_name: "proposals") || current_organization
        end

        def current_organization
          @form.current_organization
        end
      end
    end
  end
end
