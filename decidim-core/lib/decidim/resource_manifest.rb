# frozen_string_literal: true

module Decidim
  # Components inside a component can expose different Resources, these resources
  # will be used to be linked between each other and other possible components.
  #
  # This class sets a scheme to expose these resources. It shouldn't be
  # used directly, you should use `register_resource` inside a component.
  #
  # Example:
  #   component.register_resource(:my_model) do |resource|
  #     resource.model_class = Decidim::MyEngine::MyModel
  #     resource.template    = "decidim/myengine/myengine/linked_models"
  #   end
  #
  class ResourceManifest
    include ActiveModel::Model
    include Virtus.model

    # The name of the resource we are exposing.
    attribute :name, String

    # The parent component manifest
    attribute :component_manifest, Decidim::ComponentManifest

    # The ActiveRecord class name of the model we're exposing
    attribute :model_class_name, String

    # The name of the named Rails route to create the url to the resource.
    # When not explicitly set, it will use the model name.
    attribute :route_name, String

    # The template to use to render the collection of the resource.
    attribute :template, String

    # The main card to render an instance of the resource.
    attribute :card, String

    # The presenter to render an instance of the resource.
    attribute :presenter, String

    validates :model_class_name, :route_name, :name, presence: true

    # Actions are used to validate permissions of a resource against particular
    # authorizations or potentially other authorization rules.
    #
    # An example would be `vote` on a specific proposal, or `join` on a meeting.
    #
    # A resource can expose as many actions as it wants and the admin panel will
    # generate a UI to handle them. There's a set of controller helpers available
    # as well that allows checking for those permissions.
    attribute :actions, Array[String]

    # Finds an ActiveRecord::Relation of the resource `model_class`, scoped to the
    # given component. This way you can find resources from another engine without
    # actually coupling both engines. If no `component_manifest` is set for this
    # manifest, it returns an empty collection.
    #
    # component - a Decidim::Component
    #
    # Returns an ActiveRecord::Relation.
    def resource_scope(component)
      return model_class.none unless component_manifest

      component_ids = Decidim::Component.where(participatory_space: component.participatory_space, manifest_name: component_manifest.name).pluck(:id)
      return model_class.none if component_ids.empty?

      model_class.where(component: component_ids)
    end

    # Finds the current class with the given `model_class_name`
    # in order to avoid problems with Rails' autoloading.
    #
    # Returns a class.
    def model_class
      model_class_name.constantize
    end

    # The name of the named Rails route to create the url to the resource.
    #
    # Returns a String.
    def route_name
      super || model_class_name.demodulize.underscore
    end
  end
end
