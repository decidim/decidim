# frozen_string_literal: true

module Decidim
  module Elections
    # This is the engine that runs on the public interface of `decidim-elections`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Elections::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :elections do
          get :manage_trash, on: :collection

          member do
            put :publish
            put :unpublish
            patch :soft_delete
            patch :restore
            put :update_status

            get "edit_questions", to: "questions#edit_questions"
            put "update_questions", to: "questions#update"

            get "census", to: "census#edit"
            patch "census", to: "census#update"
            delete "census/destroy_all", to: "census#destroy_all", as: :destroy_all_census

            get :dashboard_page, path: "dashboard_page"
          end

          resource :census, only: [:edit, :update], controller: "census"
        end
        root to: "elections#index"
      end

      initializer "decidim_elections_admin.menu" do
        Decidim.menu :admin_elections_menu do |menu|
          election = @election
          current_component_admin_proxy = election ? Decidim::EngineRouter.admin_proxy(election.component) : nil

          menu.add_item :basic_elections,
                        I18n.t("basic_elections", scope: "decidim.admin.menu.elections_menu"),
                        @election.nil? ? new_election_path : current_component_admin_proxy&.edit_election_path(@election),
                        icon_name: "bill-line"

          menu.add_item :election_questions_edit,
                        I18n.t("election_questions", scope: "decidim.admin.menu.elections_menu"),
                        (@election.nil? || @election.published?) ? "#" : current_component_admin_proxy&.edit_questions_election_path(@election),
                        active: @election.present? && !@election.published? && is_active_link?(current_component_admin_proxy&.edit_questions_election_path(@election)),
                        icon_name: "question-answer-line"

          menu.add_item :election_census,
                        I18n.t("election_census", scope: "decidim.admin.menu.elections_menu"),
                        (@election.nil? || @election.published?) ? "#" : current_component_admin_proxy&.census_election_path(@election),
                        active: @election.present? && !@election.published? && is_active_link?(current_component_admin_proxy&.census_election_path(@election)),
                        icon_name: "group-2-line"

          menu.add_item :election_dashboard,
                        I18n.t("election_dashboard", scope: "decidim.admin.menu.elections_menu"),
                        @election.present? && @election.census_ready? ? current_component_admin_proxy&.dashboard_page_election_path(@election) : "#",
                        active: @election.present? ? is_active_link?(current_component_admin_proxy&.dashboard_page_election_path(@election)) : false,
                        icon_name: "dashboard-line"
        end
      end

      def load_seed
        nil
      end
    end
  end
end
