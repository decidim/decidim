# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class Proposal < Base
          def fields = [:body, :title]

          protected

          def query = Decidim::Proposals::Proposal.includes(:moderation)
        end
      end
    end
  end
end
