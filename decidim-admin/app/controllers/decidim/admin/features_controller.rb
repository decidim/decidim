# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class FeaturesController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      helper_method :manifest

      def index
        authorize! :read, Feature
        @manifests = Decidim.features
        @features = participatory_process.features
      end

      def new
        authorize! :create, Feature

        feature = Feature.new(
          participatory_process: participatory_process
        )

        @form = form(FeatureForm).from_model(feature).tap do |form|
          form.name = default_name(manifest)
        end
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

      private

      def manifest
        Decidim.features.find { |manifest| manifest.name == params[:type].to_sym }
      end

      def default_name(manifest)
        current_organization.available_locales.inject({}) do |result, locale|
          I18n.with_locale(locale) do
            result[locale] = I18n.t("#{manifest.name}.name", scope: "features")
          end

          result
        end
      end
    end
  end
end
