# frozen_string_literal: true

require "spec_helper"

describe "Admin export initiatives' signature" do
  include_context "when admins initiative"

  let!(:votes) { create_list(:initiative_user_vote, 5, initiative:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "downloads the PDF file", :download do
    visit decidim_admin_initiatives.initiatives_path

    within "tr", text: translated(initiative.title) do
      page.find(".action-icon--edit").click
    end

    click_on "Export PDF of signatures"
    within "#confirm-modal-content" do
      click_on "OK"
    end

    expect(File.basename(download_path)).to include("votes_#{initiative.id}.pdf")
  end
end
