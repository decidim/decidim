# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Budgets
    # This is the engine that runs on the public interface of `decidim-budgets`.
    # It mostly handles rendering the created projects associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Budgets

      routes do
        resources :budgets, only: [:index, :show] do
          resources :projects, only: [:index, :show]
          namespace :focus do
            resources :projects, only: [:index, :show]
          end
          resource :order, only: [:destroy] do
            member do
              post :checkout
              get :status
              get :export_pdf
            end
            resource :line_item, only: [:create, :destroy]
          end
        end
        scope "/budgets" do
          root to: "budgets#index"
        end
        get "/", to: redirect("budgets", status: 301)
      end

      initializer "decidim_budgets.register_icons" do
        Decidim.icons.register(name: "Decidim::Budgets::Budget", icon: "coin-line", description: "Budget", category: "activity", engine: :budgets)
        Decidim.icons.register(name: "Decidim::Budgets::Project", icon: "coin-line", description: "Project (Budgets)", category: "activity", engine: :budgets)
        Decidim.icons.register(name: "Decidim::Budgets::Order", icon: "check-double-fill", description: "Budget voting", category: "activity", engine: :budgets)

        Decidim.icons.register(name: "git-pull-request-line", icon: "git-pull-request-line", category: "system", description: "", engine: :budgets)
      end

      initializer "decidim_budgets.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Budgets::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Budgets::Engine.root}/app/views") # for partials
      end

      initializer "decidim_budgets.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_budgets.register_reminders" do
        config.after_initialize do
          Decidim.reminders_registry.register(:orders) do |reminder_registry|
            reminder_registry.generator_class_name = "Decidim::Budgets::OrderReminderGenerator"
            reminder_registry.form_class_name = "Decidim::Budgets::Admin::OrderReminderForm"
            reminder_registry.command_class_name = "Decidim::Budgets::Admin::CreateOrderReminders"

            reminder_registry.settings do |settings|
              settings.attribute :reminder_times, type: :array, default: [2.hours, 1.week, 2.weeks]
            end

            reminder_registry.messages do |msg|
              msg.set(:title) { |count: 0| I18n.t("decidim.budgets.admin.reminders.orders.title", count:) }
              msg.set(:description) { I18n.t("decidim.budgets.admin.reminders.orders.description") }
            end
          end
        end
      end

      initializer "decidim_budgets.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:budgets) do |transfer|
            transfer.move_records(Decidim::Budgets::Order, :decidim_user_id)
          end
        end
      end
    end
  end
end
