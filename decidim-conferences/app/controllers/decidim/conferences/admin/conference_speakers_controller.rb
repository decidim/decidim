# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conference speakers.
      #
      class ConferenceSpeakersController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin
        include Decidim::Paginable

        helper_method :conference_speaker, :meetings_selected

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

          CreateConferenceSpeaker.call(@form) do
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
          enforce_permission_to :update, :conference_speaker, speaker: conference_speaker
          @form = form(ConferenceSpeakerForm).from_model(conference_speaker)
        end

        def update
          enforce_permission_to :update, :conference_speaker, speaker: conference_speaker
          @form = form(ConferenceSpeakerForm).from_params(params)

          UpdateConferenceSpeaker.call(@form, conference_speaker) do
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
          enforce_permission_to :destroy, :conference_speaker, speaker: conference_speaker

          DestroyConferenceSpeaker.call(conference_speaker, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_speakers.destroy.success", scope: "decidim.admin")
              redirect_to conference_speakers_path(current_conference)
            end
          end
        end

        def publish
          enforce_permission_to(:update, :conference_speaker, speaker: conference_speaker)

          Decidim::Conferences::Admin::PublishConferenceSpeaker.call(conference_speaker, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_speakers.publish.success", scope: "decidim.admin")
              redirect_to conference_speakers_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conference_speakers.publish.invalid", scope: "decidim.admin")
              render action: "index"
            end
          end
        end

        def unpublish
          enforce_permission_to(:update, :conference_speaker, speaker: conference_speaker)

          Decidim::Conferences::Admin::UnpublishConferenceSpeaker.call(conference_speaker, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_speakers.unpublish.success", scope: "decidim.admin")
              redirect_to conference_speakers_path(current_conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conference_speakers.unpublish.invalid", scope: "decidim.admin")
              render action: "index"
            end
          end
        end

        private

        def meetings_selected
          @meetings_selected ||= @conference_speaker.conference_meetings.pluck(:id) if @conference_speaker.present?
        end

        def conference_speaker
          @conference_speaker ||= collection.find(params[:id])
        end

        def collection
          @collection ||= current_conference.speakers
        end
      end
    end
  end
end
