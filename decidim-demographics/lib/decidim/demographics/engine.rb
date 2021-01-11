# frozen_string_literal: true

require "rails"
require "decidim/core"

require_relative "query_extensions"
module Decidim
  module Demographics
    # This is the engine that runs on the public interface of demographics.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Demographics

      routes do
        # Add engine routes here
        # resources :demographics
        authenticate(:user) do
          namespace :demographics do
            get "/", action: :index, as: :index
          end
        end
      end

      initializer "decidim.action_controller" do
        Decidim::Devise::RegistrationsController.prepend Decidim::Demographics::SignInRoutes
        Decidim::Devise::OmniauthRegistrationsController.prepend Decidim::Demographics::SignInRoutes
      end

      initializer "decidim.user_menu" do
        Decidim.menu :user_menu do |menu|
          if current_organization.demographics_data_collection?
            menu.item t("demographics", scope: "layouts.decidim.user_profile"),
                      demographics_engine.new_path,
                      position: 1.0,
                      active: :exact
          end
        end
      end

      initializer "decidim_demographics.assets" do |app|
        app.config.assets.precompile += %w(decidim_demographics_manifest.js decidim_demographics_manifest.css)
      end

      initializer "decidim_demographics.query_extensions" do
        Decidim::Api::QueryType.define do
          QueryExtensions.define(self)
        end
      end
    end
  end
end
