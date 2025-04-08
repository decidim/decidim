# frozen_string_literal: true

require "icalendar"

require "decidim/core"

module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Meetings

      routes do
        resources :meetings, only: [:index, :show, :new, :create, :edit, :update, :withdraw] do
          member do
            put :withdraw
          end
          resources :meeting_closes, only: [:edit, :update] do
            get :proposals_picker, on: :collection
          end
          resource :registration, only: [:create, :destroy] do
            collection do
              get :create
              get :decline_invitation
              get :join, action: :show
              post :respond
              get :join_waitlist, action: :show
              post :join_waitlist
            end
          end
          resources :versions, only: [:show]
          resource :live_event, only: :show
          namespace :polls do
            resources :questions, only: [:index, :update]
            resources :responses, only: [:index, :create] do
              collection do
                get :admin
              end
            end
          end
        end
        scope "/meetings" do
          root to: "meetings#index"
        end
        get "/", to: redirect("meetings", status: 301)

        resource :calendar, only: [:show], format: :text do
          resources :meetings, only: [:show], controller: :calendars, action: :meeting_calendar
        end
      end

      initializer "decidim_meetings.register_icons" do
        Decidim.icons.register(name: "headphone-line", icon: "headphone-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "video-line", icon: "video-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "Decidim::Meetings::Meeting", icon: "map-pin-line", description: "Meeting", category: "activity", engine: :meetings)
        Decidim.icons.register(name: "in_person", icon: "community-line", description: "In person", category: "meetings", engine: :meetings)
        Decidim.icons.register(name: "online", icon: "webcam-line", description: "Online", category: "meetings", engine: :meetings)
        Decidim.icons.register(name: "hybrid", icon: "home-wifi-line", description: "Hybrid", category: "meetings", engine: :meetings)

        Decidim.icons.register(name: "calendar-check-line", icon: "calendar-check-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "community-line", icon: "community-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "webcam-line", icon: "webcam-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "download-cloud-2-line", icon: "download-cloud-2-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "share-forward-2-line", icon: "share-forward-2-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "home-wifi-line", icon: "home-wifi-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "coupon-line", icon: "coupon-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "door-open-line", icon: "door-open-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "broadcast-line", icon: "broadcast-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "star-line", icon: "star-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "list-ordered", icon: "list-ordered", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "bill-line", icon: "bill-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "add-box-line", icon: "add-box-line", category: "system", description: "", engine: :meetings)
        Decidim.icons.register(name: "calendar-close-line", icon: "calendar-close-line", category: "system", description: "", engine: :meetings)
      end

      initializer "decidim_meetings.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:meeting]
        end
      end

      initializer "decidim_meetings.content_security_handlers" do |_app|
        Decidim.configure do |config|
          if config.content_security_policies_extra["frame-src"].respond_to?(:<<)
            config.content_security_policies_extra["frame-src"] << "player.twitch.tv"
            config.content_security_policies_extra["frame-src"] << "meet.jit.si"
          else
            config.content_security_policies_extra["frame-src"] = %w(player.twitch.tv meet.jit.si)
          end
        end
      end

      initializer "decidim_meetings.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::HIGH_PRIORITY) do |view_context|
          view_context.cell("decidim/meetings/highlighted_meetings", view_context.current_participatory_space)
        end

        Decidim.view_hooks.register(:conference_venues, priority: Decidim::ViewHooks::HIGH_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          meetings = Decidim::Meetings::Meeting.visible.not_hidden.published.where(component: published_components).group_by(&:address)
          meetings_geocoded = Decidim::Meetings::Meeting.visible.not_hidden.published.where(component: published_components).geocoded

          next unless meetings.any?

          view_context.render(
            partial: "decidim/participatory_spaces/conference_venues",
            locals: {
              meetings:,
              meetings_geocoded:
            }
          )
        end
      end

      initializer "decidim_meetings.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Meetings::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Meetings::Engine.root}/app/views") # for partials
      end

      initializer "decidim_meetings.attended_meetings_badge" do
        Decidim::Gamification.register_badge(:attended_meetings) do |badge|
          badge.levels = [1, 3, 5, 10, 30]
          badge.reset = lambda do |user|
            Decidim::Meetings::Registration.where(user:).count
          end
        end
      end

      initializer "decidim_meetings.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_meetings.notification_settings" do
        Decidim.notification_settings(:close_meeting_reminder) { |ns| ns.settings_area = :administrators }
      end

      initializer "decidim_meetings.register_reminders" do
        config.after_initialize do
          Decidim.reminders_registry.register(:close_meeting) do |reminder_registry|
            reminder_registry.generator_class_name = "Decidim::Meetings::CloseMeetingReminderGenerator"

            reminder_registry.settings do |settings|
              settings.attribute :reminder_times, type: :array, default: [3.days, 7.days]
            end
          end
        end
      end

      initializer "decidim_meetings.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:meetings) do |transfer|
            transfer.move_records(Decidim::Meetings::Meeting, :decidim_author_id)
            transfer.move_records(Decidim::Meetings::Registration, :decidim_user_id)
            transfer.move_records(Decidim::Meetings::Response, :decidim_user_id)
          end
        end
      end

      initializer "decidim_meetings.moderation_content" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.admin.block_user:after") do |_event_name, data|
            Decidim::Meetings::HideAllCreatedByAuthorJob.perform_later(**data)
          end
        end
      end
    end
  end
end
