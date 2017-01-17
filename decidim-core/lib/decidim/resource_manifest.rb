# frozen_string_literal: true
module Decidim
  # Features inside a component can expose different Resources, these resources
  # will be used to be linked between each other and other possible features.
  #
  # This class sets a scheme to expose these resources. It shouldn't be
  # used directly, you should use `register_resource` inside a feature.
  #
  # Example:
  #   feature.register_resource do |resource|
  #     resource.model_class = Decidim::MyEngine::MyModel
  #     resource.template    = "decidim/myengine/myengine/linked_models"
  #   end
  #
  class ResourceManifest
    include ActiveModel::Model
    include Virtus.model

    # The name of the resource we are exposing.
    attribute :name, String

    # The parent feature manifest
    attribute :feature_manifest, Decidim::FeatureManifest

    # The ActiveRecord class of the model we're exposing
    attribute :model_class, ActiveRecord::Base

    # The name of the named Rails route to create the url to the resource.
    # When not explicitly set, it will use the model name.
    attribute :route_name, String

    # The template to use to render the collection of a resource.
    attribute :template, String

    validates :feature_manifest, :model_class, :route_name, presence: true

    # The name of the resource we are exposing.
    #
    # Returns a String.
    def name
      super || model_class.name.demodulize.underscore.pluralize.to_sym
    end

    # The name of the named Rails route to create the url to the resource.
    #
    # Returns a String.
    def route_name
      super || model_class.name.demodulize.underscore
    end

    # The engine for the resource. It will be used to build routes.
    #
    # Returns a Rails::Engine.
    def mounted_engine_name
      "decidim_#{feature_manifest.name}"
    end
  end
end
