# frozen_string_literal: true

require "decidim/verifications/workflows"
require "decidim/verifications/adapter"

require "decidim/verifications/postal_letter"

module Decidim
  def self.authorization_workflows
    Decidim::Verifications.workflows
  end

  def self.authorization_methods
    Verifications::Adapter.from_collection(
      authorization_handlers + authorization_workflows.map(&:name)
    )
  end
end
