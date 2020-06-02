# frozen_string_literal: true

module Decidim
  class OAuthApplication < ::Doorkeeper::Application
    include Decidim::Traceable
    include Decidim::Loggable

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization", inverse_of: :oauth_applications

    def owner
      organization
    end

    def type
      "Decidim::OAuthApplication"
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::OAuthApplicationPresenter
    end
  end
end
