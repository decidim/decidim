# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows to manage the steps of an election.
      class StepsController < Admin::ApplicationController
        helper StepsHelper
        helper_method :elections, :election, :current_step

        def index
          enforce_permission_to :read, :steps, election: election

          if current_step_form_class
            @form = form(current_step_form_class).instance(election: election)
            @form.valid?
          end
        end

        def update
          enforce_permission_to :update, :steps, election: election
          redirect_to election_steps_path(election) && return unless params[:id] == current_step

          @form = form(current_step_form_class).from_params(params, election: election)

          current_step_command_class.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("steps.#{current_step}.success", scope: "decidim.elections.admin")
              return redirect_to election_steps_path(election)
            end
            on(:invalid) do |message|
              flash.now[:alert] = message || I18n.t("steps.#{current_step}.invalid", scope: "decidim.elections.admin")
            end
          end
          render :index
        end

        private

        def current_step_form_class
          @current_step_form_class ||= {
                                         "create_election" => SetupForm
                                       }[current_step]
        end

        def current_step_command_class
          @current_step_command_class ||= {
                                            "create_election" => SetupElection
                                          }[current_step]
        end

        def current_step
          @current_step ||= election.bb_status || "create_election"
        end

        def elections
          @elections ||= Election.where(component: current_component)
        end

        def election
          @election ||= elections.find_by(id: params[:election_id])
        end
      end
    end
  end
end
