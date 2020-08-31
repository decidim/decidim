# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class AuthorizationsController < Decidim::ApplicationController
        include Decidim::Verifications::Renewable

        helper_method :authorization

        before_action :load_authorization

        def new
          @form = CensusForm.from_params(user: current_user)
          ConfirmCensusAuthorization.call(@authorization, @form, session) do
            on(:ok) do
              flash[:notice] = t("authorizations.new.success", scope: "decidim.verifications.csv_census")
            end
            on(:invalid) do
              flash[:alert] = t("authorizations.new.error", scope: "decidim.verifications.csv_census")
            end
            redirect_to decidim_verifications.authorizations_path
          end
        end

        private

        def authorization
          @authorization ||= AuthorizationPresenter.new(@authorization)
        end

        def load_authorization
          @authorization = Decidim::Authorization.find_or_initialize_by(
            user: current_user,
            name: "csv_census"
          )
        end
      end
    end
  end
end
