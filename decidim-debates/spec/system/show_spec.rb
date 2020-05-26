# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  let!(:debate) { create(:debate, component: component) }

  before do
    visit_component
    click_link debate.title[I18n.locale.to_s], class: "card__link"
  end

  context "when shows the debate component" do
    it "shows the debate title" do
      expect(page).to have_content debate.title[I18n.locale.to_s]
    end

    it_behaves_like "going back to list button"
  end
end
