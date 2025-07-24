# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conferences.
      #
      class ConferenceDuplicatesController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin

        def new
          enforce_permission_to :create, :conference
          @form = form(ConferenceDuplicateForm).from_model(current_conference)
        end

        def create
          enforce_permission_to :create, :conference
          @form = form(ConferenceDuplicateForm).from_params(params)

          DuplicateConference.call(@form, current_conference) do
            on(:ok) do
              flash[:notice] = I18n.t("conferences_duplicates.create.success", scope: "decidim.admin")
              redirect_to conferences_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conferences_duplicates.create.error", scope: "decidim.admin")
              render :new, status: :unprocessable_entity
            end
          end
        end
      end
    end
  end
end
