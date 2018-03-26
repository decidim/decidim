# frozen_string_literal: true

module Decidim
  # This cell renders the card of the given instance of a Component
  # delegated to the components' cell if specified in the manifest
  # otherwise a primary cell wil be shown.
  class CardCell < Decidim::ViewModel
    property :body
    property :title

    def show
      if resource_cell?
        cell(resource_cell, model, options)
      else
        render :show
      end
    end

    private

    def resource_cell?
      resource_cell.present?
    end

    def resource_cell
      @resource_cell ||= model.component.manifest.card
    end
  end
end
