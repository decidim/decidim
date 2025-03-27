# frozen_string_literal: true

require "spec_helper"

describe "User creates collaborative draft", type: :system do
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

  let(:command) { Decidim::Proposals::CreateCollaborativeDraft.new(form, author) }

  include_examples "Collaborative draft spam analysis"
end
