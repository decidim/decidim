# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows the create or update an election.
      class SetupController < Admin::ApplicationController
        helper_method :elections, :election

        def index
          flash.now[:alert] ||= I18n.t("elections.index.no_bulletin_board", scope: "decidim.elections.admin").html_safe unless Decidim::Elections.bulletin_board.configured?
        end

        def show
          enforce_permission_to :update, :election, election: election
          @form = form(ElectionForm).from_model(election)
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
