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

      # This is the email address used by the spam engine to
      # properly identify the user that will report users and content
      config_accessor :reporting_user_email do
        Decidim::Env.new("DECIDIM_SPAM_REPORTING_USER", "decidim-reporting-user@example.org").value
      end

      # You can configure the spam threshold for the spam detection service.
      # The threshold is a float value between 0 and 1.
      # The default value is 0.75
      # Any value below the threshold will be considered spam.
      config_accessor :resource_score_threshold do
        Decidim::Env.new("DECIDIM_SPAM_DETECTION_RESOURCE_SCORE_THRESHOLD", 0.75).to_f
      end

      # You can configure the spam delay for the spam detection service.
      # The default value is 30 seconds
      config_accessor :spam_detection_delay do
        Decidim::Env.new("DECIDIM_SPAM_DETECTION_DELAY", 30).to_i.seconds
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
      #       url: ENV["DECIDIM_SPAM_DETECTION_BACKEND_RESOURCE_URL"]
      #     }
      #   }
      # }
      config_accessor :resource_analyzers do
        [
          {
            name: :bayes,
            strategy: Decidim::Ai::SpamDetection::Strategy::Bayes,
            options: {
              adapter: ENV.fetch("DECIDIM_SPAM_DETECTION_BACKEND_RESOURCE", "redis"),
              params: { url: ENV.fetch("DECIDIM_SPAM_DETECTION_BACKEND_RESOURCE_URL", "redis://localhost:6379/2") }
            }
          }
        ]
      end

      # This config_accessor allows the implementers to change the class being used by the classifier,
      # in order to change the finder method. or even define own resource visibility criteria.
      # This is the place where new resources can be registered following the pattern
      # Resource => Handler
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

      # Spam detection service class.
      # If you want to use a different spam detection service, you can use a class service having the following contract
      config_accessor :resource_detection_service do
        Decidim::Env.new("DECIDIM_SPAM_DETECTION_RESOURCE_SERVICE", "Decidim::Ai::SpamDetection::Service").value
      end

      # You can configure the spam threshold for the spam detection service.
      # The threshold is a float value between 0 and 1.
      # The default value is 0.75
      # Any value below the threshold will be considered spam.
      config_accessor :user_score_threshold do
        Decidim::Env.new("DECIDIM_SPAM_DETECTION_USER_SCORE_THRESHOLD", 0.75).to_f
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
      #       url: ENV["DECIDIM_SPAM_DETECTION_BACKEND_USER_REDIS_URL"]
      #     }
      #   }
      # }
      config_accessor :user_analyzers do
        [
          {
            name: :bayes,
            strategy: Decidim::Ai::SpamDetection::Strategy::Bayes,
            options: {
              adapter: ENV.fetch("DECIDIM_SPAM_DETECTION_BACKEND_USER", "redis"),
              params: { url: ENV.fetch("DECIDIM_SPAM_DETECTION_BACKEND_USER_REDIS_URL", "redis://localhost:6379/3") }
            }
          }
        ]
      end

      # This config_accessor allows the implementers to change the class being used by the classifier,
      # in order to change the finder method or what a hidden user really is.
      config_accessor :user_models do
        {
          "Decidim::User" => "Decidim::Ai::SpamDetection::Resource::UserBaseEntity"
        }
      end

      # Spam detection service class.
      # If you want to use a different spam detection service, you can use a class service having the following contract
      config_accessor :user_detection_service do
        Decidim::Env.new("DECIDIM_SPAM_DETECTION_USER_SERVICE", "Decidim::Ai::SpamDetection::Service").value
      end

      # this is the generic resource classifier class. If you need to change your own class, please change the
      # configuration of `Decidim::Ai::SpamDetection.detection_service` variable.
      def self.resource_classifier
        @resource_classifier = Decidim::Ai::SpamDetection.resource_detection_service.safe_constantize&.new(
          registry: Decidim::Ai::SpamDetection.resource_registry
        )
      end

      # The registry instance that stores the list of strategies needed to process the resources
      # In essence is an enumerator class that responds to `register_analyzer(**params)` and `for(name)` methods
      def self.resource_registry
        @resource_registry ||= Decidim::Ai::StrategyRegistry.new
      end

      # this is the generic user classifier class. If you need to change your own class, please change the
      # configuration of `Decidim::Ai::SpamDetection.detection_service` variable
      def self.user_classifier
        @user_classifier = Decidim::Ai::SpamDetection.user_detection_service.safe_constantize&.new(
          registry: Decidim::Ai::SpamDetection.user_registry
        )
      end

      # The registry instance that stores the list of strategies needed to process the user objects
      # In essence is an enumerator class that responds to `register_analyzer(**params)` and `for(name)` methods
      def self.user_registry
        @user_registry ||= Decidim::Ai::StrategyRegistry.new
      end

      # This method is being called to ensure that user with email configured in
      # `Decidim::Ai::SpamDetection.reporting_user_email` variable exists in the database.
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
