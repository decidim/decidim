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

    # The ActiveRecord class name of the model we're exposing
    attribute :model_class_name, String

    # The name of the named Rails route to create the url to the resource.
    # When not explicitly set, it will use the model name.
    attribute :route_name, String

    # The template to use to render the collection of a resource.
    attribute :template, String

    validates :feature_manifest, :model_class_name, :route_name, presence: true

    # Finds an ActiveRecord::Relation of the resource `model_class`, scoped to the
    # given feature. This way you can find resources from another engine without
    # actually coupling both engines.
    #
    # feature - a Decidim::Feature
    #
    # Returns an ActiveRecord::Relation.
    def resource_scope(feature)
      feature_ids = Decidim::Feature.where(participatory_space: feature.participatory_space, manifest_name: feature_manifest.name).pluck(:id)
      return model_class.none if feature_ids.empty?

      model_class.where(feature: feature_ids)
    end

    # Finds the current class with the given `model_class_name`
    # in order to avoid problems with Rails' autoloading.
    #
    # Returns a class.
    def model_class
      model_class_name.constantize
    end

    # The name of the resource we are exposing.
    #
    # Returns a String.
    def name
      super || model_class_name.demodulize.underscore.pluralize.to_sym
    end

    # The name of the named Rails route to create the url to the resource.
    #
    # Returns a String.
    def route_name
      super || model_class_name.demodulize.underscore
    end
  end
end
