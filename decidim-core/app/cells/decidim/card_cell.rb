# frozen_string_literal: true

module Decidim
  # This cell renders the card of the given instance of a Component
  # delegated to the components' cell if specified in the manifest
  # otherwise a primary cell will be shown.
  class CardCell < Decidim::ViewModel
    ICONS_MAPPING = {
      published_at: "calendar-line",
      votings_count: "check-double-line",
      followers_count: "user-voice-line",
      participatory_space: "treasure-map-line"
    }.freeze

    def show
      if resource_cell?
        cell(resource_cell, model, options)
      else
        render :show
      end
    end

    def title
      return if title_value.blank?

      render
    end

    def metadata
      @metadata ||= stats_metadata
    end

    private

    def resource_path
      resource_locator(model).path
    end

    def icon_name(metric_key)
      ICONS_MAPPING.fetch(metric_key.to_sym, "question-line")
    end

    def resource_cell?
      return unless instance_of?(::Decidim::CardCell)

      resource_cell.present?
    end

    def resource_cell
      @resource_cell ||= if resource_card
                           resource_card
                         elsif official_author? || user_base_entity?
                           "decidim/author"
                         end
    end

    def title_value
      translated_attribute(model.try(:title) || model.try(:name) || "")
    end

    def body_value
      translated_attribute(model.try(:body) || model.try(:about) || "")
    end

    def resource_manifest
      model.try(:resource_manifest) || Decidim.find_resource_manifest(model.class)
    end

    def resource_card
      resource_manifest&.card.presence
    end

    def published_at
      return unless model.respond_to?(:published_at)

      l model.published_at, format: :decidim_short
    end

    def official_author?
      model.is_a? Decidim::OfficialAuthorPresenter
    end

    def user_base_entity?
      model.is_a?(Decidim::UserBaseEntity)
    end

    def stats
      []
    end

    def stats_metadata
      stats.map do |stat|
        { icon: icon_name(stat[:stat_title]), value: "#{number_with_delimiter(stat[:stat_number])} #{t(stat[:stat_title], scope: "decidim.statistics")}" }
      end
    end
  end
end
