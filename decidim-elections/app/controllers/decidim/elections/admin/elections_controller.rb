# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows the create or update an election.
      class ElectionsController < Admin::ApplicationController
        helper_method :elections, :election

        def new
          enforce_permission_to :create, :election
          @form = form(ElectionForm).instance
        end

        def create
          enforce_permission_to :create, :election
          @form = form(ElectionForm).from_params(params, current_component: current_component)

          CreateElection.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.create.success", scope: "decidim.elections.admin")
              redirect_to elections_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.create.invalid", scope: "decidim.elections.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :election, election: election
          @form = form(ElectionForm).from_model(election)
        end

        def update
          enforce_permission_to :update, :election, election: election
          @form = form(ElectionForm).from_params(params, current_component: current_component)

          UpdateElection.call(@form, election) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.update.success", scope: "decidim.elections.admin")
              redirect_to elections_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.update.invalid", scope: "decidim.elections.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :delete, :election, election: election

          DestroyElection.call(election, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.destroy.success", scope: "decidim.elections.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.destroy.invalid", scope: "decidim.elections.admin")
            end
          end

          redirect_to elections_path
        end

        private

        def elections
          @elections ||= Election.where(component: current_component)
        end

        def election
          @election ||= elections.find_by(id: params[:id])
        end
      end
    end
  end
end
