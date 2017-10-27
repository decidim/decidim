# frozen_string_literal: true

require "decidim/verifications/engine"
require "decidim/verifications/workflows"

require "decidim/verifications/id_documents"
require "decidim/verifications/postal_letter"
require "decidim/verifications/dummy"

module Decidim
  def self.authorization_workflows
    Decidim::Verifications.workflows
  end

  def self.authorization_engines
    Decidim::Verifications.workflows.select(&:engine)
  end

  def self.authorization_admin_engines
    Decidim::Verifications.workflows.select(&:admin_engine)
  end

  def self.authorization_handlers
    Decidim::Verifications.workflows.select(&:form)
  end
end
