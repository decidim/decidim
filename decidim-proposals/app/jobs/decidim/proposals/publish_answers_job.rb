# frozen_string_literal: true

module Decidim
  module Proposals
    class PublishAnswersJob < ApplicationJob
      def perform(component, user, proposals_ids)
        Decidim::Proposals::Admin::PublishAnswers.call(component, user, proposals_ids)
      end
    end
  end
end
