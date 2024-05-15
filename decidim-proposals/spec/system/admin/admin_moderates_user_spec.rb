# frozen_string_literal: true

require "spec_helper"

describe "Admin reports user" do
  it_behaves_like "hideable resource during block" do
    let(:reportable) { content.reload.creator.identity }

    let(:component) { create(:proposal_component, organization:) }
    let(:content) { create(:proposal, :participant_author, :published, component:) }
  end
  it_behaves_like "hideable resource during block" do
    let(:reportable) { content.reload.creator.identity }

    let(:component) { create(:proposal_component, organization:) }
    let(:content) { create(:collaborative_draft, :participant_author, :published, component:) }
  end
end
