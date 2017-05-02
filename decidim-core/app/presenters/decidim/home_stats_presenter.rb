# frozen_string_literal: true
module Decidim
  class HomeStatsPresenter < Rectify::Presenter
    attribute :organization, Decidim::Organization

    def highlighted
      render_stats(filtered_stats(primary: true))
    end

    def not_highlighted
      render_stats(filtered_stats(primary: false))
    end

    def users_count
      Decidim::User.where(organization: organization).count
    end

    def processes_count
      (OrganizationParticipatoryProcesses.new(organization) | PublicParticipatoryProcesses.new).count
    end

    private

    def render_stats(stats = {})
      safe_join(
        stats.map do |name, _stat|
          content_tag :div, "", class: "home-pam__data" do
            safe_join([
                        content_tag(:h4, I18n.t(name, scope: "pages.home.statistics"), class: "home-pam__title"),
                        content_tag(:span, Decidim.stats_for(name, published_features), class: "home-pam__number #{name}")
                      ])
          end
        end
      )
    end

    def filtered_stats(filter = {})
      Decidim.stats.select { |_name, stat| stat[:primary] == filter.fetch(:primary, false) }
    end

    def published_features
      @published_features ||= Feature.where(participatory_process: ParticipatoryProcess.published)
    end
  end
end
