# frozen_string_literal: true

module Decidim
  module Demographics
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class DirectoryEngine < ::Rails::Engine
      isolate_namespace Decidim::Demographics::Directory

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        authenticate(:user) do
          scope path: "/", controller: :demographics do
            get :new, as: :new
            patch :create
          end
        end
      end

      def load_seed
        nil
      end
    end
  end
end
