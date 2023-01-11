# frozen_string_literal: true

module Decidim
  # This cell is used to display metadata inside a list card
  # so other cells only have to customize a few methods or overwrite views.
  class CardMetadataCell < Decidim::ViewModel
    include Decidim::IconHelper

    alias resource model

    def show
      return if items.blank?

      render
    end

    def initialize(*)
      super

      @items ||= []
      @items << space_item if show_space?
    end

    private

    def enable_links?
      return true unless options.has_key?(:links)

      options[:links]
    end

    def show_space?
      (context[:show_space].presence || options[:show_space].presence) && resource.respond_to?(:participatory_space) && resource.participatory_space.present?
    end

    def participatory_space
      return unless show_space?

      @participatory_space ||= resource.participatory_space
    end

    def items
      @items.compact
    end

    def space_item
      return unless show_space?

      {
        text: translated_attribute(participatory_space.title),
        icon: resource_type_icon_key(participatory_space.class),
        url: Decidim::ResourceLocatorPresenter.new(participatory_space).path
      }
    end

    def start_date
      nil
    end

    def end_date
      nil
    end

    def dates_blank?
      [start_date, end_date].all?(&:blank?)
    end

    def current_date
      @current_date ||= Time.current.to_time
    end

    def progress_item
      return if progress_value.blank?

      {
        text: "<div class=\"card__grid-loader\" style=\"--value:#{progress_value};\"></div>#{progress_text}".html_safe
      }
    end

    def progress_value
      return if dates_blank?

      @progress_value ||= if start_date.present?
                            if current_date <= start_date || end_date.blank?
                              1
                            elsif current_date <= end_date
                              (end_date - current_date).to_f / (end_date - start_date).to_i
                            else
                              0
                            end
                          else
                            current_date <= end_date ? 1 : 0
                          end
    end

    def progress_text
      return if progress_value.blank?

      @progress_text ||= if start_date.present? && current_date < start_date
                           t("not_started", scope: "decidim.metadata.progress")
                         elsif end_date.blank?
                           t("active", scope: "decidim.metadata.progress")
                         elsif current_date < end_date
                           t("remaining", time_distance: distance_of_time_in_words(current_date, end_date), scope: "decidim.metadata.progress")
                         else
                           t("finished", scope: "decidim.metadata.progress")
                         end
    end
  end
end
