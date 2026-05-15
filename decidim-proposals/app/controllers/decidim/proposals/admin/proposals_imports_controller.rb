# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalsImportsController < Admin::ApplicationController
        def new
          enforce_permission_to :import, :proposals

          @form = form(Admin::ProposalsImportForm).instance
        end

        def create
          enforce_permission_to :import, :proposals

          @form = form(Admin::ProposalsImportForm).from_params(params)

          Admin::ImportProposals.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("proposals_imports.create.success", scope: "decidim.proposals.admin")
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals_imports.create.invalid", scope: "decidim.proposals.admin")
              render action: "new", status: :unprocessable_content
            end
          end
        end

        def component_states
          enforce_permission_to :import, :proposals
          component = current_participatory_space.components.find_by(id: params[:origin_id])

          if component
            states = Decidim::Proposals::ProposalState
                     .where(component:)
                     .map { |s| { token: s.token, title: translated_attribute(s.title) } }
            states << { token: "not_answered", title: I18n.t("decidim.proposals.answers.not_answered") }
            render json: states
          else
            render json: []
          end
        end
      end
    end
  end
end
