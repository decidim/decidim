# frozen_string_literal: true

module Decidim
  # This cell is used to display metadata inside a list card
  # so other cells only have to customize a few methods or overwrite views.
  class CardMetadataCell < Decidim::ViewModel
    include Decidim::IconHelper
    include Decidim::ApplicationHelper

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
        text: translated_attribute(participatory_space.title),
        icon: resource_type_icon_key(participatory_space.class),
        url: Decidim::ResourceLocatorPresenter.new(participatory_space).path
      }
    end

    def comments_count_item
      return unless model.is_a?(Decidim::Comments::Commentable) && model.commentable?
      return if (count = model.comments_count).zero?

      {
        text: count,
        icon: resource_type_icon_key(:comments_count)
      }
    end

    def endorsements_count_item
      return unless resource.respond_to?(:endorsements_count)

      {
        text: resource.endorsements_count,
        icon: resource_type_icon_key(:like)
      }
    end

    def author_item
      return unless authorable?

      {
        cell: "decidim/redesigned_author",
        args: [present(resource.author), { from: resource, skip_profile_link: true }]
      }
    end

    def coauthors_item
      # REDESIGN_PENDING - Define a cell to deal with coauthors of a resource.
      # For the moment this item only shows first coauthor
      return unless coauthorable?

      presented_author = official? ? "#{resource.class.module_parent}::OfficialAuthorPresenter".constantize.new : present(resource.identities.first)

      {
        cell: "decidim/redesigned_author",
        args: [presented_author, { from: resource, skip_profile_link: true }]
      }
    end

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

    def official?
      resource.respond_to?(:official?) && resource.official?
    end

    def authorable?
      @authorable ||= resource.is_a?(Decidim::Authorable)
    end

    def coauthorable?
      @coauthorable ||= resource.is_a?(Decidim::Coauthorable)
    end
  end
end
