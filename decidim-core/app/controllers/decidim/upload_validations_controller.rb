# frozen_string_literal: true

module Decidim
  class UploadValidationsController < Decidim::ApplicationController
    include FormFactory

    def create
      @form = form(Decidim::UploadValidationForm).from_params(params)

      CreateUploadValidation.call(@form) do
        on(:ok) do
          render json: { foo: "good" }
        end

        on(:invalid) do |errors|
          render json: errors
        end
      end
    end
  end
end
