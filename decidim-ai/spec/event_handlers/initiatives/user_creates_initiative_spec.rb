# frozen_string_literal: true

require "spec_helper"

describe "User creates debate", type: :system do
  let(:initiatives_type) { create(:initiatives_type, organization:) }
  let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }

  let(:form) do
    Decidim::Initiatives::InitiativeForm.from_params(
      title:,
      description:,
      type_id: initiatives_type.id,
      scope_id: scope&.scope&.id,
      signature_type: "offline",
      attachment: nil
    ).with_context(
      current_organization: organization,
      current_component: nil,
      current_user: author,
      initiative_type: initiatives_type
    )
  end
  let(:command) { Decidim::Initiatives::CreateInitiative.new(form) }

  include_examples "initiatives spam analysis"
end
