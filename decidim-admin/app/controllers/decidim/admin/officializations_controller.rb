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

        @users = Decidim::Admin::UsersOfficialization.for(current_organization, @query, @state)
                                                     .page(params[:page])
                                                     .per(15)
      end

      def new
        authorize! :new, :officializations

        @form = form(OfficializationForm).from_model(user)
      end

      def create
        authorize! :create, :officializations

        @form = form(OfficializationForm).from_params(params)

        OfficializeUser.call(@form) do
          on(:ok) do |user|
            notice = I18n.t("officializations.create.success", scope: "decidim.admin")

            redirect_to officializations_path(q: user.name), notice: notice
          end
        end
      end

      def destroy
        authorize! :destroy, :officializations

        UnofficializeUser.call(user) do
          on(:ok) do
            notice = I18n.t("officializations.destroy.success", scope: "decidim.admin")

            redirect_to officializations_path(q: user.name), notice: notice
          end
        end
      end

      private

      def user
        @user ||= Decidim::User.find_by(
          id: params[:user_id],
          organization: current_organization
        )
      end
    end
  end
end
