# frozen_string_literal: true

module Decidim
  module Ai
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Ai

      paths["db/migrate"] = nil

      initializer "decidim_ai.resource_classifiers" do |_app|
        Decidim::Ai::SpamDetection.resource_analyzers.each do |analyzer|
          Decidim::Ai::SpamDetection.resource_registry.register_analyzer(**analyzer)
        end
      end

      initializer "decidim_ai.user_classifiers" do |_app|
        Decidim::Ai::SpamDetection.user_analyzers.each do |analyzer|
          Decidim::Ai::SpamDetection.user_registry.register_analyzer(**analyzer)
        end
      end

      initializer "decidim_ai.events.subscribe_profile" do
        config.to_prepare do
          Decidim::EventsManager.subscribe("decidim.update_account:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::UserSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_comments" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.comments.create_comment:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:body])
          end
          ActiveSupport::Notifications.subscribe("decidim.comments.update_comment:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:body])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_meeting" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.meetings.create_meeting:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource], data.dig(:extra, :event_author), data.dig(:extra, :locale),
                             [:description, :title, :location_hints, :registration_terms])
          end
          ActiveSupport::Notifications.subscribe("decidim.meetings.update_meeting:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource], data.dig(:extra, :event_author), data.dig(:extra, :locale),
                             [:description, :title, :location_hints, :registration_terms])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_debate" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.debates.create_debate:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:description, :title])
          end
          ActiveSupport::Notifications.subscribe("decidim.debates.update_debate:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:description, :title])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_initiatives" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.initiatives.create_initiative:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:description, :title])
          end
          ActiveSupport::Notifications.subscribe("decidim.initiatives.update_initiative:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:description, :title])
          end
        end
      end

      initializer "decidim_ai.events.subscribe_proposals" do
        config.to_prepare do
          ActiveSupport::Notifications.subscribe("decidim.proposals.create_proposal:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:body, :title])
          end
          ActiveSupport::Notifications.subscribe("decidim.proposals.update_proposal:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:body, :title])
          end
          ActiveSupport::Notifications.subscribe("decidim.proposals.create_collaborative_draft:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:body, :title])
          end
          ActiveSupport::Notifications.subscribe("decidim.proposals.update_collaborative_draft:after") do |_event_name, data|
            Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob
              .set(wait: Decidim::Ai::SpamDetection.spam_detection_delay)
              .perform_later(data[:resource],
                             data.dig(:extra, :event_author), data.dig(:extra, :locale), [:body, :title])
          end
        end
      end

      def load_seed
        nil
      end
    end
  end
end
