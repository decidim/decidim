# frozen_string_literal: true

Decidim::Verifications.register_workflow(:postal_letter) do |workflow|
  workflow.engine = Decidim::Verifications::PostalLetter::Engine
end
