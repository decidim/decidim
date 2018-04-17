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
          helper_method :privatable_to, :authorization_object, :collection

          def index
            authorize! :read, authorization_object

            render template: "decidim/admin/participatory_space_private_users/index"
          end

          def new
            authorize! :create, authorization_object
            @form = form(ParticipatorySpacePrivateUserForm).from_params({}, privatable_to: privatable_to)
            render template: "decidim/admin/participatory_space_private_users/new"
          end

          def create
            authorize! :create, authorization_object
            @form = form(ParticipatorySpacePrivateUserForm).from_params(params, privatable_to: privatable_to)

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
            authorize! :destroy, authorization_object
            @private_user.destroy!

            flash[:notice] = I18n.t("participatory_space_private_users.destroy.success", scope: "decidim.admin")

            redirect_to after_destroy_path
          end

          def resend_invitation
            @private_user = collection.find(params[:id])
            authorize! :invite, authorization_object
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

          # Public: The Class or Object to be used with the authorization layer to
          # verify the user can manage the private users
          #
          # By default is the same as the privatable_to.
          def authorization_object
            privatable_to
          end

          def collection
            @collection ||= privatable_to.participatory_space_private_users
          end
        end
      end
    end
  end
end
