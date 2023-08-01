# frozen_string_literal: true

module Decidim
  module Ai
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Ai

      paths["db/migrate"] = nil

      initializer "decidim_ai.classifiers" do |_app|
        Decidim::Ai.registered_analyzers.each do |analyzer|
          Decidim::Ai.spam_detection_registry.register_analyzer(**analyzer)
        end
      end

      initializer "decidim_ai.events.hide_resource" do
        config.to_prepare do
          Decidim::EventsManager.subscribe("decidim.admin.hide_resource:after") do |_event_name, data|
            Decidim::Ai::TrainHiddenResourceDataJob.perform_later(data[:resource])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_profile" do
        config.to_prepare do
          Decidim::EventsManager.subscribe("decidim.update_account:after") do |_event_name, data|
            Decidim::Ai::UserSpamAnalyzerJob.perform_later(data[:resource])
          end
          Decidim::EventsManager.subscribe("decidim.admin.block_user:after") do |_event_name, data|
            Decidim::Ai::TrainUserDataJob.perform_later(data[:resource])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_comments" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.comments.create_comment:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body])
          end
          ActiveSupport::Notifications.subscribe("decidim.comments.update_comment:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_meeting" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.meetings.create_meeting:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title, :location_hints, :registration_terms])
          end
          ActiveSupport::Notifications.subscribe("decidim.meetings.update_meeting:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title, :location_hints, :registration_terms])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_debate" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.debates.create_debate:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title])
          end
          ActiveSupport::Notifications.subscribe("decidim.debates.update_debate:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_proposals" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.proposals.create_proposal:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
          end
          ActiveSupport::Notifications.subscribe("decidim.proposals.update_proposal:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
          end
          ActiveSupport::Notifications.subscribe("decidim.proposals.create_collaborative_draft:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
          end
          ActiveSupport::Notifications.subscribe("decidim.proposals.update_collaborative_draft:after") do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
          end
        end
      end

      def load_seed
        nil
      end
    end
  end
end
