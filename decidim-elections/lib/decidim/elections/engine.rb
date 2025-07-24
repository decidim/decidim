# frozen_string_literal: true

module Decidim
  module Elections
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Elections

      routes do
        resources :elections, except: [:destroy] do
          resources :votes, except: [:edit, :destroy] do
            collection do
              get :confirm
              post :cast
              get :receipt
            end
          end
          resources :per_question_votes, except: [:edit, :destroy] do
            collection do
              get :waiting
              get :receipt
            end
          end
        end
        scope "/elections" do
          root to: "elections#index"
        end
        get "/", to: redirect("elections", status: 301)
      end

      initializer "decidim_elections.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Elections::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Elections::Engine.root}/app/views") # for partials
      end

      initializer "decidim.elections.default_censuses" do |_app|
        Decidim::Elections.census_registry.register(:token_csv) do |manifest|
          manifest.admin_form = "Decidim::Elections::Admin::Censuses::TokenCsvForm"
          manifest.admin_form_partial = "decidim/elections/admin/censuses/token_csv_form"
          manifest.voter_form = "Decidim::Elections::Censuses::TokenCsvForm"
          manifest.voter_form_partial = "decidim/elections/censuses/token_csv_form"
          manifest.after_update_command = "Decidim::Elections::Admin::Censuses::TokenCsv"
          manifest.user_query do |election|
            Decidim::Elections::Voter.where(election: election)
          end
        end

        Decidim::Elections.census_registry.register(:internal_users) do |manifest|
          manifest.admin_form = "Decidim::Elections::Admin::Censuses::InternalUsersForm"
          manifest.admin_form_partial = "decidim/elections/admin/censuses/internal_users_form"
          manifest.voter_form = "Decidim::Elections::Censuses::InternalUsersForm"
          manifest.voter_form_partial = "decidim/elections/censuses/internal_users_form"
          manifest.user_query do |election|
            # These are users with granted authorizations
            # note that this does not necessarily mean that the user is authorized (as the authorization handler may have restricting attributes)
            Decidim::AuthorizedUsers.new(
              organization: election.organization,
              handlers: election.census_settings["authorization_handlers"]&.keys,
              strict: true
            ).query
          end
          # census is dynamic, so we do not need to validate it
          manifest.census_ready_validator do |_election|
            true
          end
        end
      end
    end
  end
end
