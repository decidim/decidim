# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conference media links.
      class MediaLinksController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin
        include Decidim::Paginable

        def index
          enforce_permission_to :index, :media_link

          @media_links = paginate(collection)
        end

        def new
          enforce_permission_to :create, :media_link
          @form = form(Decidim::Conferences::Admin::MediaLinkForm).instance
        end

        def create
          enforce_permission_to :create, :media_link
          @form = form(Decidim::Conferences::Admin::MediaLinkForm).from_params(params)

          CreateMediaLink.call(@form, current_user, current_conference) do
            on(:ok) do
              flash[:notice] = I18n.t("media_links.create.success", scope: "decidim.admin")
              redirect_to conference_media_links_path(current_conference)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("media_links.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @media_link = collection.find(params[:id])
          enforce_permission_to :update, :media_link, speaker: @media_link
          @form = form(MediaLinkForm).from_model(@media_link)
        end

        def update
          @media_link = collection.find(params[:id])
          enforce_permission_to :update, :media_link, speaker: @media_link
          @form = form(MediaLinkForm).from_params(params)

          UpdateMediaLink.call(@form, @media_link) do
            on(:ok) do
              flash[:notice] = I18n.t("media_links.update.success", scope: "decidim.admin")
              redirect_to conference_media_links_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("media_links.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @media_link = collection.find(params[:id])
          enforce_permission_to :destroy, :media_link, speaker: @media_link

          DestroyMediaLink.call(@media_link, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("media_links.destroy.success", scope: "decidim.admin")
              redirect_to conference_media_links_path(current_conference)
            end
          end
        end

        private

        def collection
          @collection ||= Decidim::Conferences::MediaLink.where(conference: current_conference)
        end
      end
    end
  end
end
