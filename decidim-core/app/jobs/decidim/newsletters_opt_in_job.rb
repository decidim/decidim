# frozen_string_literal: true

module Decidim
  class NewslettersOptInJob < ApplicationJob
    queue_as :newsletters_opt_in

    def perform(user, token)
      NewslettersOptInMailer.notify(user, token).deliver_now
    end
  end
end
