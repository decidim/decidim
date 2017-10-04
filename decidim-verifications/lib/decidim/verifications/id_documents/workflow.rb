# frozen_string_literal: true

Decidim::Verifications.register_workflow(:id_documents) do |workflow|
  workflow.engine = Decidim::Verifications::IdDocuments::Engine
  workflow.admin_engine = Decidim::Verifications::IdDocuments::AdminEngine
end
