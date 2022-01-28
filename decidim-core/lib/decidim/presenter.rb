# frozen_string_literal: true

module Decidim
  class Presenter < SimpleDelegator
    def organization
      __getobj__[:organization]
    end

    def attach_controller(controller)
      @controller = controller
      self
    end

    def method_missing(method_name, *args, &block)
      if view_context.respond_to?(method_name)
        view_context.public_send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      view_context.respond_to?(method_name, include_private)
    end

    private

    def controller
      @controller ||= ActionController::Base.new
    end

    def view_context
      @view_context ||= controller.view_context
    end
  end
end
