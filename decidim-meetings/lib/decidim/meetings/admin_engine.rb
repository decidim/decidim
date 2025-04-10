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
        get "/response_options", to: "registration_form#response_options", as: :response_options_meeting

        resources :meetings do
          member do
            put :publish
            put :unpublish
            patch :soft_delete
            patch :restore
          end
          resources :meeting_closes, only: [:edit, :update] do
            get :proposals_picker, on: :collection
          end
          resource :registrations, only: [:edit, :update] do
            resources :invites, only: [:index, :create]
            resource :form, only: [:edit, :update], controller: "registration_form" do
              member do
                get :edit_questions
                patch :update_questions
              end
            end
            collection do
              get :export
            end
          end
          resources :registrations_attendees, only: [:index] do
            collection do
              post :validate_registration_code
            end
            member do
              get :qr_mark_as_attendee
              put :mark_as_attendee
            end
          end
          resources :agenda, except: [:index, :destroy]
          resources :attachment_collections, except: [:show]
          resources :attachments, except: [:show]
          resources :copies, controller: "meeting_copies", only: [:new, :create]
          resource :poll, only: [:edit, :update], controller: "meetings_poll"
          get :manage_trash, on: :collection
        end
        root to: "meetings#index"
      end

      def load_seed
        nil
      end
    end
  end
end
