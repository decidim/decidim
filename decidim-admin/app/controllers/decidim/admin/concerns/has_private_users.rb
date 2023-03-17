# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      # PrivateUsers can be related to any ParticipatorySpace, in order to
      # manage the private users for a given type, you should create a new
      # controller and include this concern.
      #
      # The only requirement is to define a `privatable_to` method that
      # returns an instance of the model to relate the private_user to.
      module HasPrivateUsers
        extend ActiveSupport::Concern

        included do
          include Decidim::ParticipatorySpacePrivateUsers::Admin::Filterable
          helper PaginateHelper
          helper_method :privatable_to, :participatory_space_private_users

          def index
            enforce_permission_to :read, :space_private_user

            render template: "decidim/admin/participatory_space_private_users/index"
          end

          def new
            enforce_permission_to :create, :space_private_user
            @form = form(ParticipatorySpacePrivateUserForm).from_params({}, privatable_to:)
            render template: "decidim/admin/participatory_space_private_users/new"
          end

          def create
            enforce_permission_to :create, :space_private_user
            @form = form(ParticipatorySpacePrivateUserForm).from_params(params, privatable_to:)

            CreateParticipatorySpacePrivateUser.call(@form, current_user, current_participatory_space) do
              on(:ok) do
                flash[:notice] = I18n.t("participatory_space_private_users.create.success", scope: "decidim.admin")
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("participatory_space_private_users.create.error", scope: "decidim.admin")
                render template: "decidim/admin/participatory_space_private_users/new"
              end
            end
          end

          def destroy
            @private_user = collection.find(params[:id])
            enforce_permission_to :destroy, :space_private_user, private_user: @private_user

            DestroyParticipatorySpacePrivateUser.call(@private_user, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("participatory_space_private_users.destroy.success", scope: "decidim.admin")
                redirect_to after_destroy_path
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("participatory_space_private_users.destroy.error", scope: "decidim.admin")
                render template: "decidim/admin/participatory_space_private_users/index"
              end
            end
          end

          def resend_invitation
            @private_user = collection.find(params[:id])
            enforce_permission_to :invite, :space_private_user, private_user: @private_user
            InviteUserAgain.call(@private_user.user, "invite_private_user") do
              on(:ok) do
                flash[:notice] = I18n.t("users.resend_invitation.success", scope: "decidim.admin")
              end

              on(:invalid) do
                flash[:alert] = I18n.t("users.resend_invitation.error", scope: "decidim.admin")
              end
            end

            redirect_to after_destroy_path
          end

          # Public: Returns a String or Object that will be passed to `redirect_to` after
          # destroying a private user. By default it redirects to the privatable_to.
          #
          # It can be redefined at controller level if you need to redirect elsewhere.
          def after_destroy_path
            privatable_to
          end

          # Public: The only method to be implemented at the controller. You need to
          # return the object where the attachment will be attached to.
          def privatable_to
            raise NotImplementedError
          end

          def collection
            # there's an unidentified corner case where Decidim::User
            # may have been destroyed, but the related ParticipatorySpacePrivateUser
            # remains in the database. That's why filtering by not null users
            @collection ||= privatable_to
                            .participatory_space_private_users
                            .includes(:user).where.not("decidim_users.id" => nil)
          end

          def participatory_space_private_users
            filtered_collection
          end
        end
      end
    end
  end
end
