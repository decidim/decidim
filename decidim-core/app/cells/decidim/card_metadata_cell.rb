# frozen_string_literal: true

module Decidim
  # This cell is used to display metadata inside a list card
  # so other cells only have to customize a few methods or overwrite views.
  class CardMetadataCell < Decidim::ViewModel
    include Decidim::IconHelper
    include Decidim::ApplicationHelper
    include Decidim::SanitizeHelper
    include Decidim::DateRangeHelper
    include ActionView::Helpers::DateHelper
    include Cell::ViewModel::Partial
    include Decidim::ViewHooksHelper

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

    def space_item
      return unless show_space?

      {
        text: decidim_html_escape(translated_attribute(participatory_space.title)),
        icon: resource_type_icon_key(participatory_space.class),
        url: Decidim::ResourceLocatorPresenter.new(participatory_space).path
      }
    end

    def comments_count_item(commentable = model)
      return unless commentable.is_a?(Decidim::Comments::Commentable) && commentable.commentable?

      {
        text: commentable.comments_count,
        icon: resource_type_icon_key(:comments_count),
        data_attributes: { comments_count: "" }
      }
    end

    def endorsements_count_item
      return unless resource.respond_to?(:endorsements_count)

      {
        text: resource.endorsements_count,
        icon: resource_type_icon_key(:like),
        data_attributes: { endorsements_count: "" }
      }
    end

    def author_item
      return unless authorable?

      presented_author = official? ? "#{resource.class.module_parent}::OfficialAuthorPresenter".constantize.new : present(resource.author)

      {
        cell: "decidim/author",
        args: [presented_author, { from: resource, skip_profile_link: true, context_actions: [] }]
      }
    end

    def coauthors_item
      return unless coauthorable?

      {
        cell: "decidim/coauthorships",
        args: [resource, { stack: true }]
      }
    end

    def presenter_for_identity(identity)
      if identity.is_a?(Decidim::Organization)
        "#{model.class.module_parent}::OfficialAuthorPresenter".constantize.new
      else
        present(identity)
      end
    end

    def emendation_item
      return unless resource.try(:emendation?)

      {
        icon: resource_type_icon_key("other"),
        text: t("decidim/amendment", scope: "activerecord.models", count: 1)
      }
    end

    def dates_item
      return if dates_blank?

      {
        text: format_date_range(start_date, end_date),
        icon: "calendar-line"
      }
    end

    def duration_item
      return if dates_blank?

      {
        text: distance_of_time_in_words(start_date, end_date, scope: "datetime.distance_in_words.short"),
        icon: "time-line"
      }
    end

    def scope_item
      return unless resource.is_a?(Decidim::ScopableResource) && has_visible_scopes?(resource)

      {
        icon: resource_type_icon_key("Decidim::Scope"),
        text: translated_attribute(resource.scope.name)
      }
    end

    def category_item
      return unless resource.is_a?(Decidim::HasCategory) && resource.category.present?

      {
        text: resource.category.translated_name,
        icon: resource_type_icon_key("Decidim::Category")
      }
    end

    def enable_links?
      return false unless options.has_key?(:links)

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

    def official?
      resource.respond_to?(:official?) && resource.official?
    end

    def authorable?
      @authorable ||= resource.is_a?(Decidim::Authorable)
    end

    def coauthorable?
      @coauthorable ||= resource.is_a?(Decidim::Coauthorable)
    end

    def start_date
      nil
    end

    def end_date
      nil
    end

    def dates_blank?
      [start_date, end_date].any?(&:blank?)
    end

    def current_date
      @current_date ||= Date.current.to_time
    end

    def progress_item
      return if progress_value.blank?

      {
        text: "#{progress_span}#{progress_text}".html_safe
      }
    end

    def progress_value
      return if dates_blank?
      return 0 unless current_date <= end_date

      @progress_value ||= (end_date - current_date).to_f / (end_date - start_date)
    end

    def progress_span
      return if progress_value.blank?

      "<span class=\"card__grid-loader\" style=\"--value:#{progress_value};\"></span>"
    end

    def progress_text
      return if progress_value.blank?

      @progress_text ||= if start_date.present? && current_date < start_date
                           t("not_started", scope: "decidim.metadata.progress")
                         elsif end_date.blank?
                           t("active", scope: "decidim.metadata.progress")
                         elsif current_date < end_date
                           t("remaining", scope: "decidim.metadata.progress", time_distance: distance_of_time_in_words(current_date, end_date))
                         else
                           t("finished", scope: "decidim.metadata.progress", end_date: l(end_date.to_date, format: :decidim_short))
                         end
    end
  end
end
