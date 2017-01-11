# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing the Participatory Process' Features in the
    # admin panel.
    #
    class FeaturesController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      helper_method :manifest

      def index
        authorize! :read, Feature
        @manifests = Decidim.feature_manifests
        @features = participatory_process.features
      end

      def new
        authorize! :create, Feature

        @feature = Feature.new(
          name: default_name(manifest),
          manifest_name: params[:type],
          participatory_process: participatory_process
        )

        @form = form(FeatureForm).from_model(@feature)
      end

      def create
        @form = form(FeatureForm).from_params(params)
        authorize! :create, Feature

        CreateFeature.call(manifest, @form, participatory_process) do
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

      def edit
        @feature = participatory_process.features.find(params[:id])
        authorize! :update, @feature

        @form = form(FeatureForm).from_model(@feature).with_context(current_organization: current_organization)
      end

      def update
        @feature = participatory_process.features.find(params[:id])
        @form = form(FeatureForm).from_params(params)
        authorize! :update, @feature

        UpdateFeature.call(@form, @feature) do
          on(:ok) do
            flash[:notice] = I18n.t("features.update.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("features.update.error", scope: "decidim.admin")
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

          on(:invalid) do
            flash[:alert] = I18n.t("features.destroy.error", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end

      private

      def manifest
        Decidim.find_feature_manifest(params[:type])
      end

      def default_name(manifest)
        TranslationsHelper.multi_translation(
          "decidim.features.#{manifest.name}.name",
          current_organization.available_locales
        )
      end
    end
  end
end
