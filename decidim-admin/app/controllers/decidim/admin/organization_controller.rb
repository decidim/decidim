# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the user organization.
    #
    class OrganizationController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationForm).from_model(current_organization)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationForm).from_params(params)

        UpdateOrganization.call(current_organization, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("organization.update.success", scope: "decidim.admin")
            redirect_to edit_organization_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("organization.update.error", scope: "decidim.admin")
            render :edit
          end
        end
      end

      def users
        respond_to do |format|
          format.json do
            if (term = params[:term].to_s).present?
              query = current_organization.users.order(name: :asc)
              query = if term.start_with?("@")
                        query.where("nickname ILIKE ?", "#{term.delete("@")}%")
                      else
                        query.where("name ILIKE ?", "%#{term}%")
                      end

              render json: query.all.collect { |u| { value: u.id, label: "#{u.name} (@#{u.nickname})" } }
            else
              render json: []
            end
          end
        end
      end
    end
  end
end
