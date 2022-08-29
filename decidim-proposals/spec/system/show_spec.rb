# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposal) { create(:proposal, component:) }

  before do
    visit_component
    click_link proposal.title[I18n.locale.to_s], class: "card__link"
  end

  context "when shows the proposal component" do
    it "shows the proposal title" do
      expect(page).to have_content proposal.title[I18n.locale.to_s]
    end

    it_behaves_like "going back to list button"
  end
end
