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
          return broadcast(:invalid) unless @form.valid?

          @template = Decidim.traceability.create!(
            Template,
            @form.current_user,
            name: @form.name,
            description: @form.description,
            organization: @form.current_organization,
            field_values: { internal_state: @form.internal_state },
            target: :proposal_answer
          )

          resource = identify_templateable_resource
          @template.update!(templatable: resource)

          broadcast(:ok, @template)
        end

        private

        def identify_templateable_resource
          resource = @form.scope_for_availability.split("-")
          case resource.first
          when "organizations"
            @form.current_organization
          when "components"
            component = Decidim::Component.find_by(id: resource.last)
            component&.participatory_space&.decidim_organization_id == @form.current_organization.id ? component : nil
          end
        end
      end
    end
  end
end
