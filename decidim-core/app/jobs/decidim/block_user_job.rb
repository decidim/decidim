# frozen_string_literal: true

module Decidim
  class BlockUserJob < ApplicationJob
    queue_as :block_user

    def perform(user, justification)
      BlockUserMailer.notify(user, justification).deliver_now
    end
  end
end
