# frozen_string_literal: true

module Decidim
  module Demographics
    module Directory
      # Exposes the meeting resource so users can view them
      class DemographicsController < Decidim::ApplicationController
        include Decidim::UserProfile
        include FormFactory

        def new
          @form = demographics_form.from_model(demographics_data)
        end

        def create
          @form = demographics_form.from_params(params)

          Decidim::Demographics::RegisterDemographicsData.call(demographics_data, @form) do
            on(:ok) do
              flash[:notice] = t("data.update.success", scope: "decidim.demographics")
              redirect_to demographics_engine.new_path
            end
            on(:invalid) do
              flash.now[:alert] = I18n.t("data.update.error", scope: "decidim.demographics")
              render :new
            end
          end
        end

        protected

        def demographics_data
          Decidim::Demographics::Demographic.where(
            user: current_user,
            organization: current_user.organization
          ).first_or_create(data: {})
        end

        def demographics_form
          form(Decidim::Demographics::DemographicsForm)
        end
      end
    end
  end
end
