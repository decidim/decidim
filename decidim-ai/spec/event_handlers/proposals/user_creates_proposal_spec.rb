# frozen_string_literal: true

require "spec_helper"

describe "User creates proposal", type: :system do
  let(:form) do
    Decidim::Proposals::ProposalForm.from_params(
      title:,
      body:
    ).with_context(
      current_user: author,
      current_organization: organization,
      current_participatory_space: participatory_space,
      current_component: component
    )
  end
  let(:command) { Decidim::Proposals::CreateProposal.new(form, author) }

  include_examples "proposal spam analysis"
end
