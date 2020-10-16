# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows the create or update an election.
      class SetupController < Admin::ApplicationController
        helper_method :elections, :election, :trustees

        def index
          flash.now[:alert] ||= I18n.t("elections.index.no_bulletin_board", scope: "decidim.elections.admin").html_safe unless Decidim::Elections.bulletin_board.configured?
        end

        def show
          @form = form(SetupForm).from_model(election)
        end

        def update
          # @form = form(SetupForm).from_params(params, election: election)

          # SetupElection.call(@form, trustees, current_user) do
            # on(:ok) do
            #   flash[:notice] = I18n.t("setup.success", scope: "decidim.elections.admin")
            # end

            # on(:invalid) do
            #   flash.now[:alert] = I18n.t("setup.invalid", scope: "decidim.elections.admin")
            ##   render action: "edit"
            # end
              redirect_to election_questions_path(election)
          # end
        end

        private

        def elections
          @elections ||= Election.where(component: current_component)
        end

        def election
          @election ||= elections.find_by(id: params[:id])
        end

        def trustees
          trustees_space = TrusteesParticipatorySpace.where(participatory_space: current_participatory_space).includes(:trustee)
          @trustees ||= Trustee.where(trustees_participatory_spaces: trustees_space).includes([:user]).page(params[:page]).per(15)
        end
      end
    end
  end
end
