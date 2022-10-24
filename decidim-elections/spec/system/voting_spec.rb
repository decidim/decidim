# frozen_string_literal: true

require "spec_helper"

describe "Voting", type: :system do
  let!(:organization) { create(:organization) }
  let!(:voting) { create(:voting, :published, organization:) }
  let!(:user) { create :user, :confirmed, organization: }

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
        create(:voting, :unpublished, organization:)
      end

      before do
        switch_to_host(organization.host)
      end

      it "redirects to sign in path" do
        visit decidim_votings.voting_path(voting)
        expect(page).to have_current_path("/users/sign_in")
      end

      context "with signed in user" do
        let!(:user) { create(:user, :confirmed, organization:) }

        before do
          sign_in user, scope: :user
        end

        it "redirects to root path" do
          visit decidim_votings.voting_path(voting)
          expect(page).to have_current_path("/")
        end
      end
    end

    context "when the voting has census" do
      let!(:census) { create(:dataset, voting:) }

      before do
        switch_to_host(organization.host)
        visit decidim_votings.voting_path(voting)
      end

      it "shows 'Can I vote' tab" do
        expect(page).to have_link("Can I vote?")
      end
    end

    context "when the voting doesn't has a census" do
      before do
        switch_to_host(organization.host)
        visit decidim_votings.voting_path(voting)
      end

      it "doesn't has 'Can I vote' tab" do
        expect(page).not_to have_link("Can I vote?")
      end
    end
  end
end
