# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class Comment < Base
          def fields = [:body]

          protected

          def query = Decidim::Comments::Comment.includes(:moderation)
        end
      end
    end
  end
end
