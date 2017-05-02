module Decidim
  class HomeStatsPresenter < Rectify::Presenter
    attribute :organization, Decidim::Organization

    def users_count
      Decidim::User.where(organization: organization).count
    end

    def processes_count
      (OrganizationParticipatoryProcesses.new(organization) | PublicParticipatoryProcesses.new).count
    end

    def accepted_proposals_count
      Decidim.stats_for(:accepted_proposals_count, published_features)
    end

    def proposals_count
      Decidim.stats_for(:proposals_count, published_features)
    end

    def results_count
      Decidim.stats_for(:results_count, published_features)
    end

    def votes_count
      Decidim.stats_for(:votes_count, published_features)
    end

    def meetings_count
      Decidim.stats_for(:meetings_count, published_features)
    end

    private

    def published_features
      @published_features ||= Feature.where(participatory_process: ParticipatoryProcess.published)
    end
  end
end
