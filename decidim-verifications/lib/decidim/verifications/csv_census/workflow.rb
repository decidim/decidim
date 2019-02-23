# frozen_string_literal: true

Decidim::Verifications.register_workflow(:csv_census) do |workflow|
  workflow.engine = Decidim::Verifications::CsvCensus::Engine
  workflow.admin_engine = Decidim::Verifications::CsvCensus::AdminEngine
end
