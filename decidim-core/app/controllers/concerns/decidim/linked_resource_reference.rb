# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This module exposes a helper method to access the resource that is linked
  # to the current item, via the `included_in` parameter, and its associated
  # resource locator.
  module LinkedResourceReference
    extend ActiveSupport::Concern

    included do
      helper_method :linked_resource, :located_linked_resource
    end

    private

    def linked_resource
      @linked_resource ||= (GlobalID::Locator.locate(params[:included_in]) if params[:included_in])
    end

    def located_linked_resource
      @located_linked_resource ||= if linked_resource.is_a?(Decidim::Budgets::Project)
                                     Decidim::ResourceLocatorPresenter.new([linked_resource.budget, linked_resource])
                                   else
                                     Decidim::ResourceLocatorPresenter.new(linked_resource)
                                   end
    end
  end
end
