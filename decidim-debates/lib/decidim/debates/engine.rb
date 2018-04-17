# frozen_string_literal: true

require "searchlight"
require "kaminari"

module Decidim
  module Debates
    # This is the engine that runs on the public interface of `decidim-debates`.
    # It mostly handles rendering the created debate associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Debates

      routes do
        resources :debates, only: [:index, :show, :new, :create]
        root to: "debates#index"
      end

      initializer "decidim_debates.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += ["Decidim::Debates::Abilities::CurrentUserAbility"]
        end
      end

      initializer "decidim_changes" do
        Decidim::SettingsChange.subscribe "debates" do |changes|
          Decidim::Debates::SettingsChangeJob.perform_later(
            changes[:component_id],
            changes[:previous_settings],
            changes[:current_settings]
          )
        end
      end
    end
  end
end
