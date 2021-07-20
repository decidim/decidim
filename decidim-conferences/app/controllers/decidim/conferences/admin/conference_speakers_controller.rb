# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conference speakers.
      #
      class ConferenceSpeakersController < Decidim::Conferences::Admin::ApplicationController
        helper Decidim::Conferences::Admin::ConferenceSpeakersHelper
        include Concerns::ConferenceAdmin
        include Decidim::Paginable

        def index
          enforce_permission_to :index, :conference_speaker

          @query = params[:q]

          @conference_speakers = paginate(Decidim::Conferences::Admin::ConferenceSpeakers.for(collection, @query))
        end

        def new
          enforce_permission_to :create, :conference_speaker
          @form = form(ConferenceSpeakerForm).instance
        end

        def create
          enforce_permission_to :create, :conference_speaker
          @form = form(ConferenceSpeakerForm).from_params(params)

          CreateConferenceSpeaker.call(@form, current_user, current_conference) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_speakers.create.success", scope: "decidim.admin")
              redirect_to conference_speakers_path(current_conference)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("conference_speakers.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          @item = collection.find(params[:id])
          enforce_permission_to :update, :conference_speaker, speaker: @item
          @form = form(ConferenceSpeakerForm).from_model(@item)
        end

        def update
          @conference_speaker = collection.find(params[:id])
          enforce_permission_to :update, :conference_speaker, speaker: @conference_speaker
          @form = form(ConferenceSpeakerForm).from_params(params)

          UpdateConferenceSpeaker.call(@form, @conference_speaker) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_speakers.update.success", scope: "decidim.admin")
              redirect_to conference_speakers_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conference_speakers.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          @conference_speaker = collection.find(params[:id])
          enforce_permission_to :destroy, :conference_speaker, speaker: @conference_speaker

          DestroyConferenceSpeaker.call(@conference_speaker, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_speakers.destroy.success", scope: "decidim.admin")
              redirect_to conference_speakers_path(current_conference)
            end
          end
        end

        private

        def collection
          @collection ||= Decidim::ConferenceSpeaker.where(conference: current_conference)
        end
      end
    end
  end
end
