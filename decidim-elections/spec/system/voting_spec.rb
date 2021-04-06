# frozen_string_literal: true

require "spec_helper"

describe "Voting", type: :system do
  let!(:organization) { create(:organization) }
  let!(:voting) { create(:voting, :published, organization: organization) }
  let!(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
  end

  it_behaves_like "editable content for admins" do
    let(:target_path) { decidim_votings.voting_path(voting) }
  end

  context "when requesting the voting path" do
    before do
      visit decidim_votings.voting_path(voting)
    end

    it "shows the basic voting data" do
      expect(page).to have_i18n_content(voting.title)
      expect(page).to have_i18n_content(voting.description)
    end

    context "when the voting is unpublished" do
      let!(:voting) do
        create(:voting, :unpublished, organization: organization)
      end

      before do
        switch_to_host(organization.host)
        visit decidim_votings.voting_path(voting)
      end

      it "redirects to root path" do
        expect(page).to have_current_path("/")
      end
    end

    context "when the voting has census" do
      let!(:census) { create(:dataset, voting: voting) }

      before do
        switch_to_host(organization.host)
        visit decidim_votings.voting_path(voting)
      end

      it "shows 'How to vote' tab" do
        expect(page).to have_link("How to vote")
      end
    end

    context "when the voting doesn't has a census" do
      before do
        switch_to_host(organization.host)
        visit decidim_votings.voting_path(voting)
      end

      it "doesn't has 'How to vote' tab" do
        expect(page).not_to have_link("How to vote")
      end
    end
  end
end
