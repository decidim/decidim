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
