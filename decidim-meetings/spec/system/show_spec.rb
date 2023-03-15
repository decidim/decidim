# frozen_string_literal: true

require "spec_helper"

describe "show", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meeting) { create(:meeting, :published, component:) }

  before do
    visit_component
    click_link meeting.title[I18n.locale.to_s], class: "meeting-list"
  end

  context "when shows the meeting component" do
    it "shows the meeting title" do
      expect(page).to have_content meeting.title[I18n.locale.to_s]
    end

    # REDESIGN_PENDING - There should be recovered the back to list button,
    # removed with drawers and uncomment these shared examples
    # it_behaves_like "going back to list button"
  end
end
