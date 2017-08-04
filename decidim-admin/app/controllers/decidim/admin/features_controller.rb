# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the Participatory Process' Features in the
    # admin panel.
    #
    class FeaturesController < Decidim::Admin::ApplicationController
      helper_method :manifest, :current_participatory_space

      def index
        authorize! :read, Feature
        @manifests = Decidim.feature_manifests
        @features = current_participatory_space.features
      end

      def new
        authorize! :create, Feature

        @feature = Feature.new(
          name: default_name(manifest),
          manifest_name: params[:type],
          participatory_space: current_participatory_space
        )

        @form = form(FeatureForm).from_model(@feature)
      end

      def create
        @form = form(FeatureForm).from_params(params)
        authorize! :create, Feature

        CreateFeature.call(manifest, @form, current_participatory_space) do
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
        @feature = query_scope.find(params[:id])
        authorize! :update, @feature

        @form = form(FeatureForm).from_model(@feature)
      end

      def update
        @feature = query_scope.find(params[:id])
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
        @feature = query_scope.find(params[:id])
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

      def publish
        @feature = query_scope.find(params[:id])
        authorize! :update, @feature

        @feature.publish!

        flash[:notice] = I18n.t("features.publish.success", scope: "decidim.admin")
        redirect_to action: :index
      end

      def unpublish
        @feature = query_scope.find(params[:id])
        authorize! :update, @feature

        @feature.unpublish!

        flash[:notice] = I18n.t("features.unpublish.success", scope: "decidim.admin")
        redirect_to action: :index
      end

      private

      def query_scope
        current_participatory_space.features
      end

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
