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
              flash[:notice] = "Success" # t("organizations.update.success", scope: "decidim.system")
              redirect_to demographics_engine.new_path
            end
            on(:invalid) do
              flash.now[:alert] = "Error" # I18n.t("organizations.update.error", scope: "decidim.system")
              render :new
            end
          end
        end

        protected

        def demographics_data
          Decidim::Demographics::Demographic.where(user: current_user).first_or_create(data: {})
        end

        def demographics_form
          form(Decidim::Demographics::DemographicsForm)
        end
      end
    end
  end
end
