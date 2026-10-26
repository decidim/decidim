# frozen_string_literal: true

module Decidim
  # The controller to handle upload validations
  class UploadValidationsController < Decidim::ApplicationController
    include FormFactory

    skip_before_action :verify_organization

    before_action :underscore_params!

    def create
      enforce_permission_to :create, :upload_validation

      @form = form(Decidim::UploadValidationForm).from_params(params)

      ValidateUpload.call(@form) do
        on(:ok) do
          render json: []
        end

        on(:invalid) do |errors|
          render json: errors
        end
      end
    end

    private

    def organization_time_zone
      return Rails.application.config.time_zone unless current_organization

      super
    end

    def ensure_authenticated!
      return true unless current_organization

      super
    end

    def underscore_params!
      params.transform_keys!(&:underscore)
    end
  end
end
