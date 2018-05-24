# frozen_string_literal: true

module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Meetings::Admin

      paths["db/migrate"] = nil

      routes do
        resources :meetings do
          resources :meeting_closes, only: [:edit, :update]
          resource :registrations, only: [:edit, :update] do
            resource :invites, only: [:new, :create]
            collection do
              get :export
            end
          end
          resources :attachment_collections
          resources :attachments
          resources :copies, controller: "meeting_copies", only: [:new, :create]
          resources :minutes, except: [:show, :index]
          resources :questionnaires, except: [:show, :index]
        end
        root to: "meetings#index"
      end

      def load_seed
        nil
      end

      initializer "decidim_meetings.assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_meetings_manifest.js)
      end
    end
  end
end
