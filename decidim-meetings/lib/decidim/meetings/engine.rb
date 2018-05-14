# frozen_string_literal: true

require "searchlight"
require "kaminari"
require "jquery-tmpl-rails"
require "icalendar"
require "cells/rails"
require "cells-erb"
require "cell/partial"

module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Meetings

      routes do
        resources :meetings, only: [:index, :show] do
          resource :registration, only: [:create, :destroy] do
            collection do
              get :create
            end
          end
          resource :meeting_widget, only: :show, path: "embed"
        end
        root to: "meetings#index"
      end

      initializer "decidim_meetings.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::HIGH_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          meetings = Decidim::Meetings::Meeting.where(component: published_components)

          next unless meetings.any?

          view_context.render(
            partial: "decidim/participatory_spaces/highlighted_meetings",
            locals: {
              past_meetings: meetings.past.order(end_time: :desc, start_time: :desc).limit(3),
              upcoming_meetings: meetings.upcoming.order(:start_time, :end_time).limit(3)
            }
          )
        end

        if defined? Decidim::ParticipatoryProcesses
          Decidim::ParticipatoryProcesses.view_hooks.register(:process_group_highlighted_elements, priority: Decidim::ViewHooks::HIGH_PRIORITY) do |view_context|
            published_components = Decidim::Component.where(participatory_space: view_context.participatory_processes).published
            meetings = Decidim::Meetings::Meeting.where(component: published_components)

            next unless meetings.any?

            view_context.render(
              partial: "decidim/participatory_processes/participatory_process_groups/highlighted_meetings",
              locals: {
                past_meetings: meetings.past.order(end_time: :desc, start_time: :desc).limit(3),
                upcoming_meetings: meetings.upcoming.order(:start_time, :end_time).limit(3)
              }
            )
          end
        end

        Decidim.view_hooks.register(:assembly_meetings, priority: Decidim::ViewHooks::HIGH_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          meetings = Decidim::Meetings::Meeting.where(component: published_components)

          next unless meetings.any?

          view_context.render(
            partial: "decidim/participatory_spaces/highlighted_meetings",
            locals: {
              past_meetings: meetings.past.order(end_time: :desc, start_time: :desc).limit(3),
              upcoming_meetings: meetings.upcoming.order(:start_time, :end_time).limit(3)
            }
          )
        end
      end

      initializer "decidim_meetings.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Meetings::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Meetings::Engine.root}/app/views") # for partials
      end
    end
  end
end
