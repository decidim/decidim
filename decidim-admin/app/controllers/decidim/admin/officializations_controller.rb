# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing user groups at the admin panel.
    #
    class OfficializationsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      helper_method :user

      def index
        authorize! :index, :officializations
        @query = params[:q]
        @state = params[:state]

        @users = Decidim::Admin::UsersOfficialization.for(@query, @state)
                                                     .page(params[:page])
                                                     .per(15)
      end

      def new
        authorize! :new, :officializations

        @form = form(OfficializationForm).from_params(params)
      end

      def create
        authorize! :create, :officializations

        @form = form(OfficializationForm).from_params(params)

        OfficializeUser.call(@form) do
          on(:ok) do
            notice = I18n.t("officializations.create.success", scope: "decidim.admin")

            redirect_to officializations_path(q: @form.user.name), notice: notice
          end
        end
      end

      def destroy
        authorize! :destroy, :officializations

        @form = form(UnofficializationForm).from_params(params)

        UnofficializeUser.call(@form) do
          on(:ok) do
            notice = I18n.t("officializations.destroy.success", scope: "decidim.admin")

            redirect_to officializations_path(q: @form.user.name), notice: notice
          end
        end
      end
    end
  end
end
