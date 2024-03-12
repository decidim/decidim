# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class CollaborativeDraft < Base
          def fields = [:body, :title]

          protected

          def query = Decidim::Proposals::CollaborativeDraft.includes(:moderation)
        end
      end
    end
  end
end
