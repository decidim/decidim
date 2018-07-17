# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # one component to another.
      class ImportProposalsToBudgets < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(import_form)
          @import_form = import_form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @import_form.valid?

          broadcast(:ok, import_proposals)
        end

        private

        attr_reader :import_form, :form_project, :new_project

        def import_proposals

          proposals.each do |original_proposal|
            next if proposal_already_copied?(original_proposal, target_component)
            params = ActionController::Parameters.new(project: original_proposal.as_json)

            params[:project][:title] =  project_localized(original_proposal.title)
            params[:project][:description] =  project_localized(original_proposal.body)
            params[:project][:budget] = 10
            params[:project][:decidim_scope_id] = original_proposal.scope.id if original_proposal.scope
            params[:project][:decidim_component_id] = target_component.id
            params[:project][:decidim_category_id] = original_proposal.category.id if original_proposal.category
            params[:project][:proposal_ids] = original_proposal.id

            @project_form = form(Decidim::Budgets::Admin::ProjectForm).from_params(params)
             CreateProject.call(@project_form) do
               on(:ok) do |new_project|
                 new_project
               end

               on(:invalid) do
                 # flash.now[:alert] = I18n.t("budgets.create.error", scope: "decidim")
                 return broadcast(:invalid)
               end
             end
          end.compact
        end

        def proposals
          Decidim::Proposals::Proposal
            .where(component: origin_component)
            .where(state: "accepted")
        end

        def origin_component
          @import_form.origin_component
        end

        def target_component
          @import_form.current_component
        end

        def proposal_already_copied?(original_proposal, target_component)
          original_proposal.linked_resources(:projects, "included_proposals").any? do |proposal|
            proposal.component == target_component
          end
        end

        private

        def project_localized(text)
          Decidim.available_locales.inject({}) do |result, locale|
            result.update(locale => text)
          end.with_indifferent_access
        end
      end
    end
  end
end
