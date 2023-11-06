# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposal) { create(:proposal, component:) }

  before do
    visit_component
    click_link(id: "proposals__proposal_#{proposal.id}")
  end

  context "when shows the proposal component" do
    it "shows the proposal title" do
      expect(page).to have_content proposal.title[I18n.locale.to_s]
    end
  end
end
