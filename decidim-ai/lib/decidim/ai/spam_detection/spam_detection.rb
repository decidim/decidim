# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      include ActiveSupport::Configurable

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

      # You can configure the spam threshold for the spam detection service.
      # The threshold is a float value between 0 and 1.
      # The default value is 0.75
      # Any value below the threshold will be considered spam.
      config_accessor :resource_score_threshold do
        0.75
      end

      # You can configure the spam threshold for the spam detection service.
      # The threshold is a float value between 0 and 1.
      # The default value is 0.75
      # Any value below the threshold will be considered spam.
      config_accessor :user_score_threshold do
        0.75
      end

      def self.resource_registry
        @resource_registry ||= Decidim::Ai::StrategyRegistry.new
      end

      def self.resource_classifier
        @resource_classifier = Decidim::Ai::SpamDetection.detection_service.new(
          registry: Decidim::Ai::SpamDetection.resource_registry
        )
      end

      def self.user_classifier
        @user_classifier = Decidim::Ai::SpamDetection.detection_service.new(
          registry: Decidim::Ai::SpamDetection.user_registry
        )
      end

      def self.user_registry
        @user_registry ||= Decidim::Ai::StrategyRegistry.new
      end

      # Registered analyzers.
      # You can register your own analyzer by adding a new entry to this array.
      # The entry must be a hash with the following keys:
      # - name: the name of the analyzer
      # - strategy: the class of the strategy to use
      # - options: a hash with the options to pass to the strategy
      # Example:
      # config.resource_analyzers = {
      #   name: :bayes,
      #   strategy: Decidim::Ai::SpamContent::BayesStrategy,
      #   options: {
      #     adapter: :redis,
      #     params: {
      #       url:                lambda { ENV["REDIS_URL"] }
      #       scheme:             "redis"
      #       host:               "127.0.0.1"
      #       port:               6379
      #       path:               nil
      #       timeout:            5.0
      #       password:           nil
      #       db:                 0
      #       driver:             nil
      #       id:                 nil
      #       tcp_keepalive:      0
      #       reconnect_attempts: 1
      #       inherit_socket:     false
      #     }
      #   }
      # }
      config_accessor :resource_analyzers do
        [
          { name: :bayes, strategy: Decidim::Ai::SpamDetection::Strategy::Bayes, options: { adapter: :memory, params: {} } }
        ]
      end

      # Registered analyzers.
      # You can register your own analyzer by adding a new entry to this array.
      # The entry must be a hash with the following keys:
      # - name: the name of the analyzer
      # - strategy: the class of the strategy to use
      # - options: a hash with the options to pass to the strategy
      # Example:
      # config.user_analyzers = {
      #   name: :bayes,
      #   strategy: Decidim::Ai::SpamContent::BayesStrategy,
      #   options: {
      #     adapter: :redis,
      #     params: {
      #       url:                lambda { ENV["REDIS_URL"] }
      #       scheme:             "redis"
      #       host:               "127.0.0.1"
      #       port:               6379
      #       path:               nil
      #       timeout:            5.0
      #       password:           nil
      #       db:                 0
      #       driver:             nil
      #       id:                 nil
      #       tcp_keepalive:      0
      #       reconnect_attempts: 1
      #       inherit_socket:     false
      #     }
      #   }
      # }
      config_accessor :user_analyzers do
        [
          { name: :bayes, strategy: Decidim::Ai::SpamDetection::Strategy::Bayes, options: { adapter: :memory, params: {} } }
        ]
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
      config_accessor :detection_service do
        Decidim::Ai::SpamDetection::Service
      end

      config_accessor :resource_models do
        @models ||= begin
          models = {}
          models["Decidim::Comments::Comment"] = "Decidim::Ai::SpamDetection::Resource::Comment" if Decidim.module_installed?("comments")
          models["Decidim::Debates::Debate"] = "Decidim::Ai::SpamDetection::Resource::Debate" if Decidim.module_installed?("debates")
          models["Decidim::Initiative"] = "Decidim::Ai::SpamDetection::Resource::Initiative" if Decidim.module_installed?("initiatives")
          models["Decidim::Meetings::Meeting"] = "Decidim::Ai::SpamDetection::Resource::Meeting" if Decidim.module_installed?("meetings")
          models["Decidim::Proposals::Proposal"] = "Decidim::Ai::SpamDetection::Resource::Proposal" if Decidim.module_installed?("proposals")
          models["Decidim::Proposals::CollaborativeDraft"] = "Decidim::Ai::SpamDetection::Resource::CollaborativeDraft" if Decidim.module_installed?("proposals")
          models
        end
      end

      config_accessor :user_models do
        @user_models ||= begin
          user_models = {}

          user_models["Decidim::UserGroup"] = "Decidim::Ai::SpamDetection::Resource::UserBaseEntity"
          user_models["Decidim::User"] = "Decidim::Ai::SpamDetection::Resource::UserBaseEntity"
          user_models
        end
      end

      # This is the email address used by the spam engine to
      # properly identify the user that will report users and content
      config_accessor :reporting_user_email do
        "reporting.user@domain.tld"
      end

      def self.create_reporting_user!
        Decidim::Organization.find_each do |organization|
          user = organization.users.find_or_initialize_by(email: Decidim::Ai::SpamDetection.reporting_user_email)
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
end
