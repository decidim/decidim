# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      class TrainUserDataJob < ApplicationJob
        def perform(user)
          user.reload

          if user.blocked?
            classifier.untrain :ham, user.about
            classifier.train :spam, user.about
          else
            classifier.untrain :spam, user.about
            classifier.train :ham, user.about
          end
        end

        protected

        def classifier
          @classifier ||= Decidim::Ai::SpamDetection.user_classifier
        end
      end
    end
  end
end
