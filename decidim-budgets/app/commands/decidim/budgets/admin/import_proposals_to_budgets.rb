# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # one component to budget component.
      class ImportProposalsToBudgets < Rectify::Command
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
              next if proposal_already_copied?(original_proposal, target_component)

              project = Decidim::Budgets::Project.new
              project.title = project_localized(original_proposal.title)
              project.description = project_localized(original_proposal.body)
              project.budget = form.default_budget
              project.category = original_proposal.category
              project.component = target_component
              project.save!

              project.link_resources([original_proposal], "included_proposals")
            end.compact
          end
        end

        def proposals
          Decidim::Proposals::Proposal.where(component: origin_component).where(state: "accepted")
        end

        def origin_component
          @form.origin_component
        end

        def target_component
          @form.current_component
        end

        def proposal_already_copied?(original_proposal, target_component)
          original_proposal.linked_resources(:projects, "included_proposals").any? do |proposal|
            proposal.component == target_component
          end
        end

        def project_localized(text)
          Decidim.available_locales.inject({}) do |result, locale|
            result.update(locale => text)
          end.with_indifferent_access
        end
      end
    end
  end
end
