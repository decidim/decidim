# frozen_string_literal: true
module Decidim
  # A presenter to render statistics in the homepage.
  class HomeStatsPresenter < Rectify::Presenter
    attribute :organization, Decidim::Organization

    # Public: Render a collection of primary stats.
    def highlighted
      safe_join([
        safe_join(
          Decidim.stats.only([:users_count, :processes_count]).with_context(organization).map do |name, data|
            render_stats_data(name, data)
          end
        ),
        render_stats(priority: StatsRegistry::HIGH_PRIORITY)
      ])
    end

    # Public: Render a collection of stats that are not primary.
    def not_highlighted
      render_stats(priority: StatsRegistry::MEDIUM_PRIORITY)
    end

    private

    def render_stats(conditions)
      safe_join(
        Decidim.stats.except([:users_count, :processes_count]).filter(conditions).with_context(published_features).map do |name, data|
          render_stats_data(name, data)
        end
      )
    end

    def render_stats_data(name, data)
      content_tag :div, "", class: "home-pam__data" do
        safe_join([
                    content_tag(:h4, I18n.t(name, scope: "pages.home.statistics"), class: "home-pam__title"),
                    content_tag(:span, " #{data}", class: "home-pam__number #{name}")
                  ])
      end
    end

    def published_features
      @published_features ||= Feature.where(participatory_process: organization.participatory_processes.published)
    end
  end
end
