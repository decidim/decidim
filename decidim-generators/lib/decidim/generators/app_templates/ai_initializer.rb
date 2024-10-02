if defined?(Decidim::Ai)

  Decidim::Ai::Language.service = "Decidim::Ai::Language::Detection"
  Decidim::Ai::Language.formatter = "Decidim::Ai::Language::Formatter"

  Decidim::Ai::SpamDetection.reporting_user_email = "your-admin@example.org"

  Decidim::Ai::SpamDetection.resource_score_threshold = 0.75 # default

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
      options: { adapter: :memory, params: {} }
    }
  ]

  # If you want to use a different spam detection service, you can define your own service.
  # Refer to documentation for more details.
  #
  Decidim::Ai::SpamDetection.resource_detection_service = "Decidim::Ai::SpamDetection::Service"

  # Customize here what are the analyzed models. You may want to use this to
  # override what we register by default, or to register your own resources.
  # Follow the documentation on how to trail more resources
  Decidim::Ai::SpamDetection.resource_models = {
    "Decidim::Comments::Comment" => "Decidim::Ai::SpamDetection::Resource::Comment",
    "Decidim::Initiative" => "Decidim::Ai::SpamDetection::Resource::Initiative",
    "Decidim::Debates::Debate" => "Decidim::Ai::SpamDetection::Resource::Debate",
    "Decidim::Meetings::Meeting" => "Decidim::Ai::SpamDetection::Resource::Meeting",
    "Decidim::Proposals::Proposal" => "Decidim::Ai::SpamDetection::Resource::Proposal",
    "Decidim::Proposals::CollaborativeDraft" => "Decidim::Ai::SpamDetection::Resource::CollaborativeDraft"
  }

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
  Decidim::Ai::SpamDetection.user_analyzers = [
    {
      name: :bayes,
      strategy: Decidim::Ai::SpamDetection::Strategy::Bayes,
      options: { adapter: :memory, params: {} }
    }
  ]

  # Customize here what are the analyzed models. You may want to use this to
  # override what we register by default, or to register your own resources.
  # Follow the documentation on how to trail more resources
  Decidim::Ai::SpamDetection.user_models = {
    "Decidim::UserGroup" => "Decidim::Ai::SpamDetection::Resource::UserBaseEntity",
    "Decidim::User" => "Decidim::Ai::SpamDetection::Resource::UserBaseEntity"
  }

  # If you want to use a different spam detection service, you can define your own service.
  # Refer to documentation for more details.
  #
  Decidim::Ai::SpamDetection.user_detection_service = "Decidim::Ai::SpamDetection::Service"
end
