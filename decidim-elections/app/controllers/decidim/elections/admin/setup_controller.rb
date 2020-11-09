# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows to setup an election.
      class SetupController < Admin::ApplicationController
        helper_method :elections, :election, :trustees

        def show
          enforce_permission_to :setup, :election, election: election

          @form = form(SetupForm).from_model(election, number_of_trustees: Decidim::Elections.bulletin_board.number_of_trustees)
        end

        def update
          enforce_permission_to :setup, :election, election: election

          @form = form(SetupForm).from_params(params, election: election, trustee_ids: params[:setup][:trustee_ids])
          SetupElection.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.setup.success", scope: "decidim.elections.admin")
              redirect_to elections_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.setup.invalid", scope: "decidim.elections.admin")
            end
          end
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
