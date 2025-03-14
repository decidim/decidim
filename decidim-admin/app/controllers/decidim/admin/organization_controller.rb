# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the user organization.
    #
    class OrganizationController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationForm).from_model(current_organization)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(OrganizationForm).from_params(params)
        @form.id = current_organization.id

        UpdateOrganization.call(@form, current_organization) do
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
        search(current_organization.users.available)
      end

      private

      def search(relation)
        respond_to do |format|
          format.json do
            if (term = params[:term].to_s).present?
              query = if term.start_with?("@")
                        nickname = term.delete("@")
                        relation.where("nickname LIKE ?", "#{nickname}%")
                                .order(Arel.sql(ActiveRecord::Base.sanitize_sql_array("similarity(nickname, '#{nickname}') DESC")))
                      else
                        relation.where("name ILIKE ?", "%#{term}%").or(
                          relation.where("email ILIKE ?", "%#{term}%")
                        )
                                .order(Arel.sql(ActiveRecord::Base.sanitize_sql_array("GREATEST(similarity(name, '#{term}'), similarity(email, '#{term}')) DESC")))
                                .order(Arel.sql(ActiveRecord::Base.sanitize_sql_array("(similarity(name, '#{term}') + similarity(email, '#{term}')) / 2 DESC")))
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
