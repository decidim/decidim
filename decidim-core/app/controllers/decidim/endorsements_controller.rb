# frozen_string_literal: true

module Decidim
  # Exposes the `Endorsements` so that users can endorse resources.
  class EndorsementsController < Decidim::Components::BaseController
    helper_method :resource

    before_action :authenticate_user!

    def create
      enforce_permission_to :create, :endorsement, resource: resource
      user_group_id = params[:user_group_id]

      EndorseResource.call(resource, current_user, user_group_id) do
        on(:ok) do
          resource.reload
          render :update_buttons_and_counters
        end

        on(:invalid) do
          render json: { error: I18n.t("resource_endorsements.create.error", scope: "decidim") }, status: :unprocessable_entity
        end
      end
    end

    def destroy
      enforce_permission_to :unendorse, resource_manifest_name, resource: resource
      user_group_id = params[:user_group_id]
      user_group = user_groups.find(user_group_id) if user_group_id

      UnendorseResource.call(resource, current_user, user_group) do
        on(:ok) do
          resource.reload
          render :update_buttons_and_counters
        end
      end
    end

    def identities
      enforce_permission_to :endorse, resource_manifest_name, resource: resource

      @user_verified_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
      render :identities, layout: false
    end

    private

    def user_groups
      Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
    end

    def resource
      @resource ||= begin
        clazz= params[:resource_type].constantize
        clazz.where(component: current_component).find(params[:resource_id])
      end
    end

    def resource_manifest_name
      @manifest_name||= resource.component.manifest.name
    end
  end
end
