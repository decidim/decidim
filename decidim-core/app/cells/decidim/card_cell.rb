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
      @resource_cell ||= if resource_card
                           resource_card
                         elsif official_author? || user_or_user_group?
                           "decidim/author"
                         end
    end

    def title
      model.try(:title) || model.try(:name) || ""
    end

    def body
      model.try(:body) || model.try(:about) || ""
    end

    def resource_manifest
      model.try(:resource_manifest) || Decidim.find_resource_manifest(model.class)
    end

    def resource_card
      resource_manifest&.card.presence
    end

    def official_author?
      ["Decidim::Proposals::OfficialAuthorPresenter", "Decidim::Debates::OfficialAuthorPresenter"].include? model.class.to_s
    end

    def user_or_user_group?
      ["Decidim::User", "Decidim::UserGroup"].include? model.model_name.name
    end
  end
end
