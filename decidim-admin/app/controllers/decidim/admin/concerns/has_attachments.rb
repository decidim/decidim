# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      # Attachments can be related to any class in Decidim, in order to
      # manage the attachments for a given type, you should create a new
      # controller and include this concern.
      #
      # The only requirement is to define a `attached_to` method that
      # returns an instance of the model to attach the attachment to.
      module HasAttachments
        extend ActiveSupport::Concern

        included do
          helper_method :attached_to, :authorization_object

          def index
            authorize! :read, authorization_object

            render template: "decidim/admin/attachments/index"
          end

          def new
            authorize! :create, authorization_object
            @form = form(AttachmentForm).instance
            render template: "decidim/admin/attachments/new"
          end

          def create
            authorize! :create, authorization_object
            @form = form(AttachmentForm).from_params(params)

            CreateAttachment.call(@form, attached_to) do
              on(:ok) do
                flash[:notice] = I18n.t("attachments.create.success", scope: "decidim.admin")
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("attachments.create.error", scope: "decidim.admin")
                render template: "decidim/admin/attachments/new"
              end
            end
          end

          def edit
            @attachment = collection.find(params[:id])
            authorize! :update, authorization_object
            @form = form(AttachmentForm).from_model(@attachment)
            render template: "decidim/admin/attachments/edit"
          end

          def update
            @attachment = collection.find(params[:id])
            authorize! :update, authorization_object
            @form = form(AttachmentForm).from_params(attachment_params)

            UpdateAttachment.call(@attachment, @form) do
              on(:ok) do
                flash[:notice] = I18n.t("attachments.update.success", scope: "decidim.admin")
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("attachments.update.error", scope: "decidim.admin")
                render template: "decidim/admin/attachments/edit"
              end
            end
          end

          def show
            @attachment = collection.find(params[:id])
            authorize! :read, authorization_object
            render template: "decidim/admin/attachments/show"
          end

          def destroy
            @attachment = collection.find(params[:id])
            authorize! :destroy, authorization_object
            @attachment.destroy!

            flash[:notice] = I18n.t("attachments.destroy.success", scope: "decidim.admin")

            redirect_to after_destroy_path
          end

          # Public: Returns a String or Object that will be passed to `redirect_to` after
          # destroying an attachment. By default it redirects to the attached_to.
          #
          # It can be redefined at controller level if you need to redirect elsewhere.
          def after_destroy_path
            attached_to
          end

          # Public: The only method to be implemented at the controller. You need to
          # return the object where the attachment will be attached to.
          def attached_to
            raise NotImplementedError
          end

          # Public: The Class or Object to be used with the authorization layer to
          # verify the user can manage the attachments
          #
          # By default is the same as the attached_to.
          def authorization_object
            attached_to
          end

          def collection
            @collection ||= attached_to.attachments
          end

          private

          def attachment_params
            {
              id: params[:id],
              file: @attachment.file
            }.merge(params[:attachment].to_unsafe_h)
          end
        end
      end
    end
  end
end
