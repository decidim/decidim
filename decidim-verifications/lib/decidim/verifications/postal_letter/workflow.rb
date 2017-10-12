# frozen_string_literal: true

Decidim::Verifications.register_workflow(:postal_letter) do |workflow|
  workflow.engine = Decidim::Verifications::PostalLetter::Engine
  workflow.admin_engine = Decidim::Verifications::PostalLetter::AdminEngine
end
