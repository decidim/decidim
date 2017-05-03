# frozen_string_literal: true
module Decidim
  # A presenter to render statistics in the homepage.
  class HomeStatsPresenter < Rectify::Presenter
    attribute :organization, Decidim::Organization

    # Public: Render a collection of primary stats.
    def highlighted
      render_stats(filtered_stats(primary: true))
    end

    # Public: Render a collection of stats that are not primary.
    def not_highlighted
      render_stats(filtered_stats(primary: false))
    end

    # Public: Render the number of users for the current organization.
    def users_count
      render_stats_data(
        :users_count,
        Decidim::User.where(organization: organization).count
      )
    end

    # Public: Render the number of published participatory processes for the current organization.
    def processes_count
      render_stats_data(
        :processes_count,
        (OrganizationParticipatoryProcesses.new(organization) | PublicParticipatoryProcesses.new).count
      )
    end

    private

    def render_stats(stats = {})
      safe_join(
        stats.map do |name, _stat|
          render_stats_data(name, Decidim.stats_for(name, published_features))
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

    def filtered_stats(filter = {})
      Decidim.stats.select { |_name, stat| stat[:primary] == filter.fetch(:primary, false) }
    end

    def published_features
      @published_features ||= Feature.where(participatory_process: organization.participatory_processes.published)
    end
  end
end
