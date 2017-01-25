# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A factory to build forms. This is done to add a context when possible, so
  # that forms can act based on data that varies between requests. This is
  # mostly done so that i18n form fields can be properly validated with the
  # `current_organization` available locales, instead of doing so against all
  # the available locales in the platform. The `current_organization` varies
  # between requests, so the form need some way to access this data.
  #
  # Examples:
  #
  #   # in a controller, mostly in a `create` action:
  #   form(MyFormClass).form_params(params)
  #
  #   # in a controller, mostly in a `new` action:
  #   form(MyFormClass).instance
  #
  #   # in a controller, mostly in an `edit` action:
  #   form(MyFormClass).form_model(@my_resource)
  #
  module FormFactory
    extend ActiveSupport::Concern

    included do
      # Initializes a factory for the given Form Object class.
      #
      # klass - a Form object class name. Must be a constant, not a String.
      def form(klass)
        Class.new do
          # Initializes the form factory object.
          #
          # klass - the class name of the Form object that will be initialized
          # controller - the Controller where the form is built.
          def initialize(klass, controller)
            @klass = klass
            @controller = controller
          end

          # Returns a simple instance of the form klass.
          #
          # extra_context - A Hash with optional extra context data.
          def instance(extra_context = {})
            @klass.new.with_context(context.merge(extra_context))
          end

          # Initializes a form object from a model. Delegates the functionality
          # to the form object class method.
          #
          # model         - the model instance from which the form object will be
          #                 initialized.
          # extra_context - a Hash with optional context data.
          def from_model(model, extra_context = {})
            @klass.from_model(model).with_context(context.merge(extra_context))
          end

          # Initializes a form object instance from params, and it
          # automatically adds some context. Context can be extended.
          #
          # params        - a Hash with params. Mostly a set of params from a form.
          # extra_context - a Hash with optional context data.
          def from_params(params, extra_context = {})
            @klass.from_params(params).with_context(context.merge(extra_context))
          end

          # Sets a base context from the current controller. Since this can be
          # used from some controllers that do not respond to the helper
          # methods used here, this Hash can have different keys depending on
          # the controller that uses it.
          def context
            {
              current_organization: @controller.try(:current_organization),
              current_feature: @controller.try(:current_feature),
              current_user: @controller.try(:current_user)
            }
          end
        end.new(klass, self)
      end
    end
  end
end
