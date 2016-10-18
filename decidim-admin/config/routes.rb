# frozen_string_literal: true
Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resources :participatory_processes do
      resources :steps, controller: "participatory_process_steps", except: :index
    end
    root to: "dashboard#show"
  end
end
