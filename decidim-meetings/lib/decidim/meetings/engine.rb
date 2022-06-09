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
              post :answer
            end
          end
          resources :versions, only: [:show, :index]
          resource :widget, only: :show, path: "embed"
          resource :live_event, only: :show
          namespace :polls do
            resources :questions, only: [:index, :update]
            resources :answers, only: [:index, :create]
          end
        end
        root to: "meetings#index"
        resource :calendar, only: [:show], format: :text do
          resources :meetings, only: [:show], controller: :calendars, action: :meeting_calendar
        end
      end

      initializer "decidim.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:meeting]
        end
      end

      initializer "decidim_meetings.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::HIGH_PRIORITY) do |view_context|
          view_context.cell("decidim/meetings/highlighted_meetings", view_context.current_participatory_space)
        end

        # This view hook is used in card cells. It renders the next upcoming
        # meeting for the given participatory space.
        Decidim.view_hooks.register(:upcoming_meeting_for_card, priority: Decidim::ViewHooks::LOW_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          upcoming_meeting = Decidim::Meetings::Meeting.where(component: published_components).upcoming.order(:start_time, :end_time).first

          next unless upcoming_meeting

          view_context.render(
            partial: "decidim/participatory_spaces/upcoming_meeting_for_card.html",
            locals: {
              upcoming_meeting: upcoming_meeting
            }
          )
        end

        Decidim.view_hooks.register(:conference_venues, priority: Decidim::ViewHooks::HIGH_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          meetings = Decidim::Meetings::Meeting.where(component: published_components).group_by(&:address)
          meetings_geocoded = Decidim::Meetings::Meeting.where(component: published_components).geocoded
          next unless meetings.any?

          view_context.render(
            partial: "decidim/participatory_spaces/conference_venues",
            locals: {
              meetings: meetings,
              meetings_geocoded: meetings_geocoded
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
            Decidim::Meetings::Registration.where(user: user).count
          end
        end
      end

      initializer "decidim_meetings.register_metrics" do
        Decidim.metrics_registry.register(:meetings) do |metric_registry|
          metric_registry.manager_class = "Decidim::Meetings::Metrics::MeetingsMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(home participatory_process)
            settings.attribute :weight, type: :integer, default: 5
            settings.attribute :stat_block, type: :string, default: "small"
          end
        end

        Decidim.metrics_operation.register(:followers, :meetings) do |metric_operation|
          metric_operation.manager_class = "Decidim::Meetings::Metrics::MeetingFollowersMetricMeasure"
        end
      end

      initializer "decidim_meetings.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_meetings.notification_settings" do
        Decidim.notification_settings(:close_meeting_reminder) { |ns| ns.settings_area = :administrators }
      end

      initializer "decidim_meetings.register_reminders" do
        Decidim.reminders_registry.register(:close_meeting) do |reminder_registry|
          reminder_registry.generator_class_name = "Decidim::Meetings::CloseMeetingReminderGenerator"

          reminder_registry.settings do |settings|
            settings.attribute :reminder_times, type: :array, default: [3.days, 7.days]
          end
        end
      end
    end
  end
end
