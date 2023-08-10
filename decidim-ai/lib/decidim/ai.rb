# frozen_string_literal: true

require "decidim/ai/engine"

module Decidim
  module Ai
    autoload :StrategyRegistry, "decidim/ai/strategy_registry"

    module LanguageDetection
      autoload :Service, "decidim/ai/language_detection/service"
    end

    module SpamDetection
      autoload :Service, "decidim/ai/spam_detection/service"

      module Resource
        autoload :Base, "decidim/ai/spam_detection/resource/base"
        autoload :Comment, "decidim/ai/spam_detection/resource/comment"
        autoload :Debate, "decidim/ai/spam_detection/resource/debate"
        autoload :Initiative, "decidim/ai/spam_detection/resource/initiative"
        autoload :Proposal, "decidim/ai/spam_detection/resource/proposal"
        autoload :CollaborativeDraft, "decidim/ai/spam_detection/resource/collaborative_draft"
        autoload :Meeting, "decidim/ai/spam_detection/resource/meeting"
        autoload :UserBaseEntity, "decidim/ai/spam_detection/resource/user_base_entity"
      end

      module Importer
        autoload :File, "decidim/ai/spam_detection/importer/file"
        autoload :Database, "decidim/ai/spam_detection/importer/database"
      end

      module Strategy
        autoload :Base, "decidim/ai/spam_detection/strategy/base"
        autoload :Bayes, "decidim/ai/spam_detection/strategy/bayes"
      end
    end

    include ActiveSupport::Configurable

    # You can configure the spam treshold for the spam detection service.
    # The treshold is a float value between 0 and 1.
    # The default value is 0.5
    # Any value below the treshold will be considered spam.
    config_accessor :spam_treshold do
      0.75
    end
    # Registered analyzers.
    # You can register your own analyzer by adding a new entry to this array.
    # The entry must be a hash with the following keys:
    # - name: the name of the analyzer
    # - strategy: the class of the strategy to use
    # - options: a hash with the options to pass to the strategy
    # Example:
    # config.registered_analyzers = [
    #   {
    #     name: :bayes,
    #     strategy: Decidim::Ai::SpamContent::BayesStrategy,
    #     options: {
    #       adapter: :redis,
    #       params: {
    #         url:                lambda { ENV["REDIS_URL"] }
    #         scheme:             "redis"
    #         host:               "127.0.0.1"
    #         port:               6379
    #         path:               nil
    #         timeout:            5.0
    #         password:           nil
    #         db:                 0
    #         driver:             nil
    #         id:                 nil
    #         tcp_keepalive:      0
    #         reconnect_attempts: 1
    #         inherit_socket:     false
    #       }
    #     }
    #   }
    # ]
    config_accessor :registered_analyzers do
      [
        { name: :bayes, strategy: Decidim::Ai::SpamDetection::Strategy::Bayes, options: { adapter: :memory, params: {} } }
      ]
    end

    # Language detection service class.
    #
    # If you want to autodetect the language of the content, you can use a class service having the following contract
    #
    # class LanguageDetectionService
    #   def initialize(text)
    #     @text = text
    #   end
    #
    #   def language_code
    #     CLD.detect_language(@text).fetch(:code)
    #   end
    # end
    config_accessor :language_detection_service do
      "Decidim::Ai::LanguageDetection::Service"
    end

    # Spam detection service class.
    # If you want to use a different spam detection service, you can use a class service having the following contract
    #
    # class SpamDetection::Service
    #   def initialize
    #     @registry = Decidim::Ai.spam_detection_registry
    #   end
    #
    #   def train(category, text)
    #     # train the strategy
    #   end
    #
    #   def classify(text)
    #     # classify the text
    #   end
    #
    #   def untrain(category, text)
    #     # untrain the strategy
    #   end
    #
    #   def classification_log
    #     # return the classification log
    #   end
    # end
    config_accessor :spam_detection_service do
      "Decidim::Ai::SpamDetection::Service"
    end

    # This is the email address used by the spam engine to
    # properly identify the user that will report users and content
    config_accessor :reporting_user_email do
      "reporting.user@domain.tld"
    end

    config_accessor :trained_models do
      @models = {
        "Decidim::UserGroup" => "Decidim::Ai::SpamDetection::Resource::UserBaseEntity",
        "Decidim::User" => "Decidim::Ai::SpamDetection::Resource::UserBaseEntity"
      }

      @models["Decidim::Comments::Comment"] = "Decidim::Ai::SpamDetection::Resource::Comment" if Decidim.module_installed?("comments")
      @models["Decidim::Debates::Debate"] = "Decidim::Ai::SpamDetection::Resource::Debate" if Decidim.module_installed?("debates")
      @models["Decidim::Initiative"] = "Decidim::Ai::SpamDetection::Resource::Initiative" if Decidim.module_installed?("initiatives")
      @models["Decidim::Meetings::Meeting"] = "Decidim::Ai::SpamDetection::Resource::Meeting" if Decidim.module_installed?("meetings")
      @models["Decidim::Proposals::Proposal"] = "Decidim::Ai::SpamDetection::Resource::Proposal" if Decidim.module_installed?("proposals")
      @models["Decidim::Proposals::CollaborativeDraft"] = "Decidim::Ai::SpamDetection::Resource::CollaborativeDraft" if Decidim.module_installed?("proposals")

      @models
    end

    def self.spam_detection_instance
      @spam_detection_instance ||= spam_detection_service.constantize.new
    end

    def self.spam_detection_registry
      @spam_detection ||= Decidim::Ai::StrategyRegistry.new
    end

    def self.create_reporting_users!
      Decidim::Organization.find_each do |organization|
        user = organization.users.find_or_initialize_by(email: Decidim::Ai.reporting_user_email)
        next if user.persisted?

        password = SecureRandom.hex(10)
        user.password = password
        user.password_confirmation = password

        user.deleted_at = Time.current
        user.tos_agreement = true
        user.name = ""
        user.skip_confirmation!
        user.save!
      end
    end
  end
end
