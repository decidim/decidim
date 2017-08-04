# frozen_string_literal: true

module Decidim
  # A presenter to render statistics in the homepage.
  class HomeStatsPresenter < Rectify::Presenter
    attribute :organization, Decidim::Organization

    # Public: Render a collection of primary stats.
    def highlighted
      highlighted_stats = Decidim.stats.only([:users_count, :processes_count]).with_context(organization).map { |name, data| [name, data] }
      highlighted_stats = highlighted_stats.concat(global_stats(priority: StatsRegistry::HIGH_PRIORITY))
      highlighted_stats = highlighted_stats.concat(feature_stats(priority: StatsRegistry::HIGH_PRIORITY))
      highlighted_stats = highlighted_stats.reject(&:empty?)
      highlighted_stats = highlighted_stats.reject { |_name, data| data.zero? }

      safe_join(
        highlighted_stats.in_groups_of(2, false).map do |stats|
          content_tag :div, class: "home-pam__highlight" do
            safe_join(
              stats.map do |name, data|
                render_stats_data(name, data)
              end
            )
          end
        end
      )
    end

    # Public: Render a collection of stats that are not primary.
    def not_highlighted
      not_highlighted_stats = global_stats(priority: StatsRegistry::MEDIUM_PRIORITY)
      not_highlighted_stats = not_highlighted_stats.concat(feature_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
      not_highlighted_stats = not_highlighted_stats.reject(&:empty?)
      not_highlighted_stats = not_highlighted_stats.reject { |_name, data| data.zero? }

      safe_join(
        not_highlighted_stats.in_groups_of(3, [:empty]).map do |stats|
          content_tag :div, class: "home-pam__lowlight" do
            safe_join(
              stats.map do |name, data|
                render_stats_data(name, data)
              end
            )
          end
        end
      )
    end

    private

    def global_stats(conditions)
      Decidim.stats.except([:users_count, :processes_count])
             .filter(conditions)
             .with_context(published_features)
             .map { |name, data| [name, data] }
    end

    def feature_stats(conditions)
      Decidim.feature_manifests.map do |feature|
        feature.stats.filter(conditions).with_context(published_features).map { |name, data| [name, data] }.flatten
      end
    end

    def render_stats_data(name, data)
      content_tag :div, "", class: "home-pam__data" do
        if name == :empty
          "&nbsp;".html_safe
        else
          safe_join([
                      content_tag(:h4, I18n.t(name, scope: "pages.home.statistics"), class: "home-pam__title"),
                      content_tag(:span, " #{number_with_delimiter(data)}", class: "home-pam__number #{name}")
                    ])
        end
      end
    end

    def published_features
      @published_features ||= Feature.where(participatory_space: ParticipatoryProcesses::OrganizationPublishedParticipatoryProcesses.new(organization).query).published
    end
  end
end
