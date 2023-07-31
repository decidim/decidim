# frozen_string_literal: true

module Decidim
  module Ai
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
    end
  end
end
