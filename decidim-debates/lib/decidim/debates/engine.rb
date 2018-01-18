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
        resources :debates, only: [:index, :show]
        root to: "debates#index"
      end

      initializer "decidim_debates.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += ["Decidim::Debates::Abilities::CurrentUserAbility"]
        end
      end
    end
  end
end
