# frozen_string_literal: true

module Decidim
  # This cell is used to render public activities performed by users.
  #
  # Each model that we want to represent should inherit from this cell and
  # tweak the necessary methods (usually `title` is enough).
  class ActivityCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::IconHelper
    include Decidim::ApplicationHelper
    include Decidim::SanitizeHelper
    include ActionView::Helpers::DateHelper

    def show
      return unless renderable?

      render
    end

    # Since activity logs could be linked to resource no longer available
    # this method is added in order to skip rendering a cell if there is
    # not enough data.
    def renderable?
      resource.present? && participatory_space.present? && published?
    end

    # The resource linked to the activity.
    def resource
      model.resource_lazy
    end

    # The title to show at the card.
    #
    # The card will also be displayed OK if there is no title.
    def title
      resource_title = resource.try(:resource_title) || resource.try(:title)
      return if resource_title.blank?

      case resource_title
      when String
        resource_title
      when Hash
        translated_attribute(resource_title)
      end
    end

    # The description to show at the card.
    #
    # The card will also be displayed OK if there is no description.
    def description
      resource_description = resource.try(:resource_description) || resource.try(:description)
      return if resource_description.blank?

      resource_description = case resource_description
                             when String
                               resource_description
                             when Hash
                               translated_attribute(resource_description)
                             end

      truncate(strip_tags(resource_description), length: 300)
    end

    # The link to the resource linked to the activity.
    def resource_link_path
      resource_locator(resource).path
    end

    # The text to show as the link to the resource.
    def resource_link_text
      decidim_html_escape(translated_attribute(resource.title))
    end

    def created_at
      t("decidim.activity.time_ago", time: time_ago_in_words(model.created_at))
    end

    def user
      return resource.normalized_author if resource.respond_to?(:normalized_author)
      return resource.author if resource.respond_to?(:author)
      # As Proposals have Coauthorable concern instead of Authorable
      return resource.identities.first if resource.respond_to?(:identities)

      model.user_lazy if resource.respond_to?(:user)
    end

    delegate :action, to: :model

    def element_id
      "action-#{model.id}"
    end

    def cache_hash
      hash = []
      hash << I18n.locale.to_s
      hash << model.class.name.underscore
      hash << model.cache_key_with_version
      if (author_cell = author)
        hash.push(Digest::MD5.hexdigest(author_cell.send(:cache_hash)))
      end

      hash.join(Decidim.cache_key_separator)
    end

    private

    def published?
      return true unless resource.respond_to?(:published?)

      resource.published?
    end

    def component
      model.component_lazy
    end

    def organization
      model.organization_lazy
    end

    def author
      return unless show_author? && user.is_a?(UserBaseEntity)

      presenter = case user
                  when Decidim::User
                    UserPresenter.new(user)
                  when Decidim::UserGroup
                    UserGroupPresenter.new(user)
                  end

      return unless presenter

      cell "decidim/author", presenter
    end

    def participatory_space
      return resource if resource.is_a?(Decidim::Participable)

      model.participatory_space_lazy
    end

    def participatory_space_link
      link_to(
        decidim_html_escape(translated_attribute(participatory_space.title)),
        resource_locator(participatory_space).path
      )
    end

    def show_author?
      context[:show_author]
    end
  end
end
