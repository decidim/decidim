# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conferences.
      #
      class ConferenceCopiesController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin

        def new
          enforce_permission_to :create, :conference
          @form = form(ConferenceCopyForm).from_model(current_conference)
        end

        def create
          enforce_permission_to :create, :conference
          @form = form(ConferenceCopyForm).from_params(params)

          CopyConference.call(@form, current_conference) do
            on(:ok) do
              flash[:notice] = I18n.t("conferences_copies.create.success", scope: "decidim.admin")
              redirect_to conferences_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conferences_copies.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end
      end
    end
  end
end
