# frozen_string_literal: true

module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Meetings::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        get "/answer_options", to: "registration_form#answer_options", as: :answer_options_meeting

        resources :meetings do
          resources :meeting_closes, only: [:edit, :update] do
            get :proposals_picker, on: :collection
          end
          resource :registrations, only: [:edit, :update] do
            resources :invites, only: [:index, :create]
            resource :form, only: [:edit, :update], controller: "registration_form"
            collection do
              get :export
              post :validate_registration_code
            end
          end
          resources :agenda, except: [:index, :destroy]
          resources :attachment_collections
          resources :attachments
          resources :copies, controller: "meeting_copies", only: [:new, :create]
          resources :minutes, except: [:show, :index]
        end
        root to: "meetings#index"
      end

      def load_seed
        nil
      end
    end
  end
end
