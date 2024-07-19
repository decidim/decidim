# frozen_string_literal: true

require "spec_helper"

describe "User updates meeting", type: :system do
  let(:form) do
    Decidim::Initiatives::InitiativeForm.from_params(
      title:,
      description:,
      type_id: initiative&.type&.id,
      scope_id: initiative&.scope&.id,
      signature_type: initiative.signature_type,
      attachment: nil
    ).with_context(
      current_organization: organization,
      initiative_type: initiative&.type,
      current_user: author
    )
  end
  let(:command) { Decidim::Initiatives::UpdateInitiative.new(initiative, form) }

  context "when initiative is published" do
    include_examples "initiatives spam analysis" do
      let!(:initiative) do
        create(:initiative,
               :open,
               organization:,
               author:,
               title: { "en" => "Some proposal that is not blocked" },
               description: { "en" => "The body for the proposal." })
      end
    end
  end

  context "when initiative is draft" do
    include_examples "initiatives spam analysis" do
      let!(:initiative) do
        create(:initiative,
               :created,
               organization:,
               author:,
               title: { "en" => "Some proposal that is not blocked" },
               description: { "en" => "The body for the proposal." })
      end
    end
  end
end
