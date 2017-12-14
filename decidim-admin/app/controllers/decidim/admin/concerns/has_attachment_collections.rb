# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      # Attachment collections can be related to an attachment, in order to
      # manage the attachment collections for a given type, you should create
      # a new controller and include this concern.
      #
      # The only requirement is to define a `current_participatory_space` method that
      # returns an instance of the model that will hold the attachment collection.
      module HasAttachmentCollections
        extend ActiveSupport::Concern

        included do
          helper_method :current_participatory_space, :authorization_object

          def index
            authorize! :read, authorization_object

            render template: "decidim/admin/attachment_collections/index"
          end

          def new
            authorize! :create, authorization_object
            @form = form(AttachmentCollectionForm).from_params({}, current_participatory_space: current_participatory_space)
            render template: "decidim/admin/attachment_collections/new"
          end

          def create
            authorize! :create, authorization_object
            @form = form(AttachmentCollectionForm).from_params(params, current_participatory_space: current_participatory_space)

            CreateAttachmentCollection.call(@form, current_participatory_space) do
              on(:ok) do
                flash[:notice] = I18n.t("attachment_collections.create.success", scope: "decidim.admin")
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("attachment_collections.create.error", scope: "decidim.admin")
                render template: "decidim/admin/attachment_collections/new"
              end
            end
          end

          def edit
            @attachment_collection = collection.find(params[:id])
            authorize! :update, authorization_object
            @form = form(AttachmentCollectionForm).from_model(@attachment_collection, current_participatory_space: current_participatory_space)
            render template: "decidim/admin/attachment_collections/edit"
          end

          def update
            @attachment_collection = collection.find(params[:id])
            authorize! :update, authorization_object
            @form = form(AttachmentCollectionForm).from_params(params, current_participatory_space: current_participatory_space)

            UpdateAttachmentCollection.call(@attachment_collection, @form) do
              on(:ok) do
                flash[:notice] = I18n.t("attachment_collections.update.success", scope: "decidim.admin")
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("attachment_collections.update.error", scope: "decidim.admin")
                render template: "decidim/admin/attachment_collections/edit"
              end
            end
          end

          def show
            @attachment_collection = collection.find(params[:id])
            authorize! :read, authorization_object
            render template: "decidim/admin/attachment_collections/show"
          end

          def destroy
            @attachment_collection = collection.find(params[:id])
            authorize! :destroy, authorization_object
            @attachment_collection.destroy!

            flash[:notice] = I18n.t("attachment_collections.destroy.success", scope: "decidim.admin")

            redirect_to after_destroy_path
          end

          # Public: Returns a String or Object that will be passed to `redirect_to` after
          # destroying an attachment collection. By default it redirects to the current
          # participatory space.
          #
          # It can be redefined at controller level if you need to redirect elsewhere.
          def after_destroy_path
            current_participatory_space
          end

          # Public: The only method to be implemented at the controller. You need to
          # return the object that will hold the attachment collection.
          def current_participatory_space
            raise NotImplementedError
          end

          # Public: The Class or Object to be used with the authorization layer to
          # verify the user can manage the attachment collection
          #
          # By default is the same as the current_participatory_space.
          def authorization_object
            current_participatory_space
          end

          def collection
            @collection ||= current_participatory_space.attachment_collections
          end
        end
      end
    end
  end
end
