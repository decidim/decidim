# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      # TODO: Documentation

      class AuthorizationsController < Decidim::ApplicationController
        helper_method :authorization

        before_action :load_authorization

        def new
          @form = CensusForm.new
        end

        def create
          @form = CensusForm.from_params(params.merge(user: current_user))
          ConfirmCensusAuthorization.call(@authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.csv_census")
              redirect_to decidim_verifications.authorizations_path
            end
            on(:invalid) do
              flash.now[:alert] = t("authorizations.create.error", scope: "decidim.verifications.csv_census")
              render :new
            end
          end
        end

        private

        def authorization
          @authorization ||= AuthorizationPresenter.new(@authorization)
        end

        def load_authorization
          @authorization = Decidim::Authorization.find_or_create_by(
            user: current_user,
            name: "csv_census"
          )
        end
      end
    end
  end
end
