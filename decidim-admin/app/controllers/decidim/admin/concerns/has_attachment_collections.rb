# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      # Attachment collections can be related to an attachment, in order to
      # manage the attachment collections for a given type, you should create
      # a new controller and include this concern.
      #
      # The only requirement is to define a `collection_for` method that
      # returns an instance of the model that will hold the attachment collection.
      module HasAttachmentCollections
        extend ActiveSupport::Concern

        included do
          helper_method :collection_for, :attachment_collection

          def index
            enforce_permission_to :read, :attachment_collection

            render template: "decidim/admin/attachment_collections/index"
          end

          def new
            enforce_permission_to :create, :attachment_collection
            @form = form(AttachmentCollectionForm).from_params({}, collection_for:)
            render template: "decidim/admin/attachment_collections/new"
          end

          def create
            enforce_permission_to :create, :attachment_collection
            @form = form(AttachmentCollectionForm).from_params(params, collection_for:)

            CreateAttachmentCollection.call(@form, collection_for, current_user) do
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
            enforce_permission_to :update, :attachment_collection, attachment_collection: @attachment_collection
            @form = form(AttachmentCollectionForm).from_model(@attachment_collection, collection_for:)
            render template: "decidim/admin/attachment_collections/edit"
          end

          def update
            @attachment_collection = collection.find(params[:id])
            enforce_permission_to :update, :attachment_collection, attachment_collection: @attachment_collection
            @form = form(AttachmentCollectionForm).from_params(params, collection_for:)

            UpdateAttachmentCollection.call(@attachment_collection, @form, current_user) do
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
            enforce_permission_to :read, :attachment_collection, attachment_collection: @attachment_collection
            render template: "decidim/admin/attachment_collections/show"
          end

          def destroy
            @attachment_collection = collection.find(params[:id])
            enforce_permission_to :destroy, :attachment_collection, attachment_collection: @attachment_collection

            Decidim.traceability.perform_action!("delete", @attachment_collection, current_user) do
              @attachment_collection.destroy!
            end

            flash[:notice] = I18n.t("attachment_collections.destroy.success", scope: "decidim.admin")

            redirect_to after_destroy_path
          end

          # Public: Returns a String or Object that will be passed to `redirect_to` after
          # destroying an attachment collection. By default it redirects to the object
          # that holds the attachment collection.
          #
          # It can be redefined at controller level if you need to redirect elsewhere.
          def after_destroy_path
            collection_for
          end

          # Public: The only method to be implemented at the controller. You need to
          # return the object that will hold the attachment collection.
          def collection_for
            raise NotImplementedError
          end

          def collection
            @collection ||= collection_for.attachment_collections
          end
        end
      end
    end
  end
end
