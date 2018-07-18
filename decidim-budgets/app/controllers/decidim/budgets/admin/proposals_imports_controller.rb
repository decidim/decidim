# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class ProposalsImportsController < Admin::ApplicationController
        def new
          enforce_permission_to :import_proposals, :projects

          @form = form(Admin::ProjectImportProposalsForm).instance
        end

        def create
          enforce_permission_to :import_proposals, :projects

          @form = form(Admin::ProjectImportProposalsForm).from_params(params)
          @project_forms = proposals_to_project_forms(params[:proposals_import][:default_budget])

          Admin::ImportProposalsToBudgets.call(@form, @project_forms) do
            on(:ok) do |_projects|
              flash[:notice] = I18n.t("proposals_imports.create.success", scope: "decidim.budgets.admin", number: @project_forms.length)
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("proposals_imports.create.invalid", scope: "decidim.budgets.admin")
              render action: "new"
            end
          end
        end

        private

        def proposals_to_project_forms(default_budget)
          rs = []

          proposals.each do |original_proposal|
            next if proposal_already_copied?(original_proposal, target_component)
            params = ActionController::Parameters.new(project: original_proposal.as_json)

            params[:project][:title] = project_localized(original_proposal.title)
            params[:project][:description] = project_localized(original_proposal.body)
            params[:project][:budget] = default_budget
            params[:project][:decidim_scope_id] = original_proposal.scope.id if original_proposal.scope
            params[:project][:decidim_component_id] = target_component.id
            params[:project][:decidim_category_id] = original_proposal.category.id if original_proposal.category
            params[:project][:proposal_ids] = original_proposal.id

            r = form(Decidim::Budgets::Admin::ProjectForm).from_params(params)
            rs << r
          end
          rs
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
