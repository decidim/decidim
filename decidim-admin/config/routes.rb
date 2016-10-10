# frozen_string_literal: true
Decidim::Admin::Engine.routes.draw do
  constraints(->(request) { Decidim::Admin::OrganizationDashboardConstraint.new(request).matches? }) do
    resources :participatory_processes
    root to: "dashboard#show"
  end
end
