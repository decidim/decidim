# frozen_string_literal: true

if Decidim.module_installed?(:ai)

  # When the engine is consistently marking spam content without errors,
  # you can skip human intervention by enabling this functionality
  Decidim::Ai::SpamDetection.hide_reported_resources_automatically = false

  Decidim::Ai::Language.formatter = "Decidim::Ai::Language::Formatter"

  Decidim::Ai::SpamDetection.reporting_user_email = "your-admin@example.org"

  Decidim::Ai::SpamDetection.resource_score_threshold = 0.75 # default

  Decidim::Ai::SpamDetection.spam_detection_delay = 30.seconds # default

  # The entry must be a hash with the following keys:
  # - name: the name of the analyzer
  # - strategy: the class of the strategy to use
  # - options: a hash with the options to pass to the strategy
  # Example:
  # Decidim::Ai::SpamDetection.resource_analyzers = [
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
  Decidim::Ai::SpamDetection.resource_analyzers = [
    {
      name: :bayes,
      strategy: Decidim::Ai::SpamDetection::Strategy::Bayes,
      options: {
        adapter: ENV.fetch("DECIDIM_SPAM_DETECTION_BACKEND_RESOURCE", "redis"),
        params: { url: ENV.fetch("DECIDIM_SPAM_DETECTION_BACKEND_RESOURCE_REDIS_URL", "redis://localhost:6379/2") }
      }
    }
  ]

  # If you want to use a different spam detection service, you can define your own service.
  # Refer to documentation for more details.
  #
  Decidim::Ai::SpamDetection.resource_detection_service = "Decidim::Ai::SpamDetection::Service"

  # Customize here what are the analyzed models. You may want to use this to
  # override what we register by default, or to register your own resources.
  # Follow the documentation on how to trail more resources
  Decidim::Ai::SpamDetection.resource_models = begin
    models = {}
    models["Decidim::Comments::Comment"] = "Decidim::Ai::SpamDetection::Resource::Comment" if Decidim.module_installed?("comments")
    models["Decidim::Debates::Debate"] = "Decidim::Ai::SpamDetection::Resource::Debate" if Decidim.module_installed?("debates")
    models["Decidim::Initiative"] = "Decidim::Ai::SpamDetection::Resource::Initiative" if Decidim.module_installed?("initiatives")
    models["Decidim::Meetings::Meeting"] = "Decidim::Ai::SpamDetection::Resource::Meeting" if Decidim.module_installed?("meetings")
    models["Decidim::Proposals::Proposal"] = "Decidim::Ai::SpamDetection::Resource::Proposal" if Decidim.module_installed?("proposals")
    models["Decidim::Proposals::CollaborativeDraft"] = "Decidim::Ai::SpamDetection::Resource::CollaborativeDraft" if Decidim.module_installed?("proposals")
    models
  end

  Decidim::Ai::SpamDetection.user_score_threshold = 0.75 # default

  # The entry must be a hash with the following keys:
  # - name: the name of the analyzer
  # - strategy: the class of the strategy to use
  # - options: a hash with the options to pass to the strategy
  # Example:
  # Decidim::Ai::SpamDetection.user_analyzers = [
  #   {
  #     name: :bayes,
  #     strategy: Decidim::Ai::SpamContent::BayesStrategy,
  #     options: {
  #       adapter: :redis,
  #       params: {
  #         url:                lambda { ENV["REDIS_URL"] }
  #       }
  #     }
  #   }
  # ]
  Decidim::Ai::SpamDetection.user_analyzers = [
    {
      name: :bayes,
      strategy: Decidim::Ai::SpamDetection::Strategy::Bayes,
      options: {
        adapter: ENV.fetch("DECIDIM_SPAM_DETECTION_BACKEND_USER", "redis"),
        params: { url: ENV.fetch("DECIDIM_SPAM_DETECTION_BACKEND_USER_REDIS_URL", "redis://localhost:6379/3") }
      }
    }
  ]

  # Customize here what are the analyzed models. You may want to use this to
  # override what we register by default, or to register your own resources.
  # Follow the documentation on how to trail more resources
  Decidim::Ai::SpamDetection.user_models = {
    "Decidim::User" => "Decidim::Ai::SpamDetection::Resource::UserBaseEntity"
  }

  # If you want to use a different spam detection service, you can define your own service.
  # Refer to documentation for more details.
  #
  Decidim::Ai::SpamDetection.user_detection_service = "Decidim::Ai::SpamDetection::Service"
end
