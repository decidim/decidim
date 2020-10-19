# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows the create or update an election.
      class SetupController < Admin::ApplicationController
        helper_method :elections, :election, :trustees

        def show
          enforce_permission_to :setup, :election, election: election
          @form = form(SetupForm).from_model(election, number_of_trustees: 2)
        end

        def update
          @form = form(SetupForm).from_params(params, election: election, trustee_ids: params[:setup][:trustee_ids])
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
