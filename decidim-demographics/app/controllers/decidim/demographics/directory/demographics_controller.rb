# frozen_string_literal: true

module Decidim
  module Demographics
    module Directory
      # Exposes the meeting resource so users can view them
      class DemographicsController < Decidim::ApplicationController
        include Decidim::UserProfile
        include FormFactory

        def new
          @form = demographics_form.instance
        end

        def create
          @form = demographics_form.instance
        end

        protected

        def demographics_form
          form(Decidim::Demographics::DemographicsForm)
        end
      end
    end
  end
end
