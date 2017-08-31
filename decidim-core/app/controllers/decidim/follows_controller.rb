# frozen_string_literal: true

module Decidim
  class FollowsController < Decidim::ApplicationController
    include FormFactory
    before_action :authenticate_user!

    def destroy
      @form = form(Decidim::FollowForm).from_params(params)
      authorize! :delete, @form
    end

    def create
      @form = form(Decidim::FollowForm).from_params(params)
      authorize! :create, Follow

      CreateFollow.call(@form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("decidim.reports.create.success")
          redirect_back fallback_location: root_path
        end

        on(:invalid) do
          flash[:alert] = I18n.t("decidim.reports.create.error")
          redirect_back fallback_location: root_path
        end
      end
    end
  end
end
