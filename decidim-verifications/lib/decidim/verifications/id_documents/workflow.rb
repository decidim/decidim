# frozen_string_literal: true

Decidim::Verifications.register_workflow(:id_documents) do |workflow|
  workflow.engine = Decidim::Verifications::IdDocuments::Engine
end
