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

            get "edit_questions", to: "questions#edit_questions"
            patch "update_questions", to: "questions#update_questions"
          end

          resources :questions, controller: "questions" do
            collection do
              post :reorder
            end

            resources :answers, controller: "answers" do
              post :reorder, on: :collection
            end
          end
        end
        root to: "elections#index"
      end

      initializer "decidim_elections_admin.menu" do
        Decidim.menu :admin_elections_menu do |menu|
          menu.add_item :basic_elections,
                        I18n.t("basic_elections", scope: "decidim.admin.menu.elections_menu"),
                        @election.nil? ? new_election_path : Decidim::EngineRouter.admin_proxy(@election.component).edit_election_path(@election),
                        icon_name: "bill-line"

          menu.add_item :election_questions_edit,
                        I18n.t("election_questions", scope: "decidim.admin.menu.elections_menu"),
                        @election.nil? ? "#" : Decidim::EngineRouter.admin_proxy(@election.component).edit_questions_election_path(@election),
                        icon_name: "question-answer-line"
        end
      end

      def load_seed
        nil
      end
    end
  end
end
