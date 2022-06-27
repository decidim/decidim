# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # one component to projects of a budget.
      class ImportProposalsToBudgets < Decidim::Command
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
          return broadcast(:invalid) unless @form.valid?

          broadcast(:ok, create_projects_from_accepted_proposals)
        end

        private

        attr_reader :form

        def create_projects_from_accepted_proposals
          transaction do
            proposals.map do |original_proposal|
              next if proposal_already_copied?(original_proposal)

              new_project = create_project_from_proposal!(original_proposal)

              new_project.link_resources([original_proposal], "included_proposals")
            end.compact
          end
        end

        def create_project_from_proposal!(original_proposal)
          params = {
            budget: form.budget,
            title: original_proposal.title,
            description: original_proposal.body,
            budget_amount: budget_for(original_proposal),
            category: original_proposal.category,
            scope: original_proposal.scope,
            address: original_proposal.address,
            latitude: original_proposal.latitude,
            longitude: original_proposal.longitude
          }

          @project = Decidim.traceability.create!(
            Project,
            form.current_user,
            params,
            visibility: "all"
          )
        end

        def budget_for(original_proposal)
          return form.default_budget if original_proposal.cost.blank?

          original_proposal.cost
        end

        def proposals
          return all_proposals if form.scope_id.blank?

          all_proposals.where(decidim_scope_id: form.scope_id)
        end

        def all_proposals
          Decidim::Proposals::Proposal.where(component: origin_component)
                                      .where(state: :accepted)
        end

        def origin_component
          form.origin_component
        end

        def proposal_already_copied?(original_proposal)
          original_proposal.linked_resources(:projects, "included_proposals").any? do |project|
            project.budget == form.budget
          end
        end
      end
    end
  end
end
