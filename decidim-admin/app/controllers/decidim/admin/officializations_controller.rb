# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing user officializations at the admin panel.
    #
    class OfficializationsController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Officializations::Filterable

      layout "decidim/admin/users"

      helper_method :user
      helper Decidim::Messaging::ConversationHelper

      def index
        enforce_permission_to :read, :officialization
        @users = filtered_collection
      end

      def new
        enforce_permission_to :create, :officialization

        @form = form(OfficializationForm).from_model(user)
      end

      def create
        enforce_permission_to :create, :officialization

        @form = form(OfficializationForm).from_params(params)

        OfficializeUser.call(@form) do
          on(:ok) do |user|
            notice = I18n.t("officializations.create.success", scope: "decidim.admin")

            redirect_to officializations_path(q: { name_or_nickname_or_email_cont: user.name }), notice:
          end
        end
      end

      def destroy
        enforce_permission_to :destroy, :officialization

        UnofficializeUser.call(user, current_user) do
          on(:ok) do
            notice = I18n.t("officializations.destroy.success", scope: "decidim.admin")

            redirect_to officializations_path(q: { name_or_nickname_or_email_cont: user.name }), notice:
          end
        end
      end

      def show_email
        enforce_permission_to :show_email, :user, user: user

        Decidim.traceability.perform_action! :show_email, user, current_user

        render :show_email, layout: false
      end

      private

      def collection
        @collection ||= current_organization.users.not_deleted.left_outer_joins(:user_moderation)
      end

      def user
        @user ||= Decidim::User.find_by(
          id: params[:user_id],
          organization: current_organization
        )
      end
    end
  end
end
