# frozen_string_literal: true

module Decidim
  # This cell renders the card of the given instance of a Component
  # delegated to the components' cell if specified in the manifest
  # otherwise a primary cell wil be shown.
  class CardCell < Decidim::ViewModel
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
      if model.respond_to?(:resource_manifest) && model.resource_manifest.card.present?
        @resource_cell ||= model.resource_manifest.card
      elsif ["Decidim::Proposals::OfficialAuthorPresenter", "Decidim::Debates::OfficialAuthorPresenter"].include? model.class.to_s
        @resource_cell ||= "decidim/author"
      elsif ["Decidim::User", "Decidim::UserGroup"].include? model.model_name.name
        @resource_cell ||= "decidim/author"
      end
    end

    def title
      model.try(:title) || model.try(:name) || ""
    end

    def body
      model.try(:body) || model.try(:about) || ""
    end
  end
end
