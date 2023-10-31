# frozen_string_literal: true

require "spec_helper"

describe "show" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meeting) { create(:meeting, :published, component:) }

  before do
    visit_component
    click_link meeting.title[I18n.locale.to_s]
  end

  context "when shows the meeting component" do
    it "shows the meeting title" do
      expect(page).to have_content meeting.title[I18n.locale.to_s]
    end
  end
end
