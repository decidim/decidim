# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class FeaturesController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def index
        authorize! :read, Feature
        @manifests = Decidim.features
        @features = participatory_process.features
      end

      def new
        @feature_manifest = Decidim.features.find do |manifest|
          manifest.name == params[:type].to_sym
        end

        authorize! :create, Feature

        feature = Feature.new(
          participatory_process: participatory_process,
          feature_type: @feature_manifest.name
        )

        @form = FeatureForm.from_model(feature)
      end

      def create
        @form = FeatureForm.from_params(params)
        authorize! :create, Feature

        CreateFeature.call(@form, participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("features.create.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("features.create.error", scope: "decidim.admin")
            render action: "new"
          end
        end
      end

      def destroy
        @feature = participatory_process.features.find(params[:id])
        authorize! :destroy, @feature

        DestroyFeature.call(@feature) do
          on(:ok) do
            flash[:notice] = I18n.t("features.destroy.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:error) do
            flash.now[:alert] = I18n.t("features.destroy.error", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end
    end
  end
end
