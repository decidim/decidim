# frozen_string_literal: true

module Decidim
  module Elections
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Elections

      routes do
        resources :elections, only: [:index, :show]
        scope "/elections" do
          root to: "elections#index"
        end
        get "/", to: redirect("/elections", status: 301)
      end

      initializer "decidim.elections.default_censuses" do |_app|
        Decidim::Elections.census_registry.register(:token_csv) do |manifest|
          manifest.admin_form = "Decidim::Elections::Admin::Censuses::TokenCsvForm"
          manifest.admin_form_partial = "decidim/elections/admin/censuses/token_csv_form"
          manifest.after_update_command = "Decidim::Elections::Admin::Censuses::TokenCsv"
          manifest.user_query(&:voters)
        end

        Decidim::Elections.census_registry.register(:internal_users) do |manifest|
          manifest.admin_form = "Decidim::Elections::Admin::Censuses::InternalUsersForm"
          manifest.admin_form_partial = "decidim/elections/admin/censuses/internal_users_form"
          manifest.user_query do |election|
            Decidim::AuthorizedUsers.new(
              organization: election.organization,
              handlers: election.census_settings["verification_handlers"].presence
            ).query
          end
          # census is dynamic so we do not need to validate it
          manifest.census_ready_validator do |_election|
            true
          end
        end
      end
    end
  end
end
