# frozen_string_literal: true

module Decidim
  module Demographics
    module Directory
      # Exposes the meeting resource so users can view them
      class DemographicsController < Decidim::ApplicationController
        include Decidim::UserProfile
        include FormFactory

        def new
          @demographic_data = JSON.parse(current_user.extended_data["demographic_data"])
          @form = demographics_form.instance
        end

        def create
          demographic_data = {
            gender: params[:demographics]["gender"],
            age: params[:demographics]["age"],
            nationalities: params[:demographics]["nationalities"],
            postal_code: params[:demographics]["postal_code"],
            background: params[:demographics]["background"]
          }
          @current_user.extended_data[:demographic_data] = demographic_data.to_json
          respond_to do |format|
            if @current_user.save
              format.html { redirect_back fallback_location: demographics_engine_path, notice: I18n.t('demographics.successfully_saved') }
            else
              flash.now[:error]= I18n.t('demographics.not_saved_successfully')
              format.html { render :new }
            end
          end
        end

        protected

        def demographics_form
          form(Decidim::Demographics::DemographicsForm)
        end
      end
    end
  end
end
