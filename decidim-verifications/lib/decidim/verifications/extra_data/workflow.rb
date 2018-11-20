# frozen_string_literal: true

Decidim::Verifications.register_workflow(:extra_data) do |workflow|
  workflow.engine = Decidim::Verifications::ExtraData::Engine
  workflow.admin_engine = Decidim::Verifications::ExtraData::AdminEngine
end
