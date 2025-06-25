# frozen_string_literal: true

require "spec_helper"

describe "User updates proposal", type: :system do
  let(:form) do
    Decidim::Proposals::ProposalForm.from_params(
      title:,
      body:,
      address: nil,
      has_address: false,
      attachment: nil,
      photos: [],
      add_photos: [],
      documents: [],
      add_documents: [],
      errors: double.as_null_object
    ).with_context(
      current_organization: organization,
      current_participatory_space: participatory_space,
      current_component: component
    )
  end
  let(:command) { Decidim::Proposals::UpdateProposal.new(form, author, proposal) }

  context "when proposal is published" do
    include_examples "proposal spam analysis" do
      let!(:proposal) do
        create(:proposal,
               :published,
               component:,
               users: [author],
               title: "Some proposal that is not blocked",
               body: "The body for the proposal.")
      end
    end
  end

  context "when proposal is draft" do
    include_examples "proposal spam analysis" do
      let!(:proposal) do
        create(:proposal,
               :draft,
               component:,
               users: [author],
               title: "Some draft that is not blocked",
               body: "The body for the proposal.")
      end
    end
  end
end
