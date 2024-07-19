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
    end
  end
end
