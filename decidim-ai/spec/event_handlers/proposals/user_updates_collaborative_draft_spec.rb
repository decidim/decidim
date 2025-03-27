# frozen_string_literal: true

require "spec_helper"

describe "User updates collaborative draft", type: :system do
  let(:form) do
    Decidim::Proposals::CollaborativeDraftForm.from_params(
      title:,
      body:,
      address: nil,
      has_address: false,
      latitude: 40.1234,
      longitude: 2.1234,
      add_documents: nil,
      suggested_hashtags: []
    ).with_context(
      current_user: author,
      current_organization: organization,
      current_participatory_space: participatory_space,
      current_component: component
    )
  end

  let(:command) do
    Decidim::Proposals::UpdateCollaborativeDraft.new(form, author, collaborative_draft)
  end

  include_examples "Collaborative draft spam analysis" do
    let!(:collaborative_draft) do
      create(:collaborative_draft,
             component:,
             users: [author],
             title: "Some draft that is not blocked",
             body: "The body for the proposal.")
    end
  end
end
