# frozen_string_literal: true

require "spec_helper"

describe "Initiative signing", type: :system do
  let(:organization) { create(:organization) }
  let(:initiative) do
    create(:initiative, :published, organization: organization)
  end
  let(:confirmed_user) { create(:user, :confirmed, organization: organization) }

  before do
    allow(Decidim::Initiatives)
      .to receive(:do_not_require_authorization)
      .and_return(true)
    switch_to_host(organization.host)
    login_as confirmed_user, scope: :user
  end

  context "when the user has not signed the initiative yet and signs it" do
    context "when the user has a verified user group" do
      let!(:user_group) { create :user_group, :verified, users: [confirmed_user], organization: confirmed_user.organization }

      it "votes as a user group" do
        vote_initiative(user_name: user_group.name)
      end

      it "votes as themselves" do
        vote_initiative(user_name: confirmed_user.name)
      end
    end

    it "adds the signature" do
      vote_initiative
    end
  end

  context "when the user has signed the initiative and unsigns it" do
    context "when the user has a verified user group" do
      let!(:user_group) { create :user_group, :verified, users: [confirmed_user], organization: confirmed_user.organization }

      it "removes the signature" do
        vote_initiative(user_name: user_group.name)

        click_button user_group.name

        within ".view-side" do
          expect(page).to have_content("0\nSIGNATURE")
        end
      end
    end

    it "removes the signature" do
      vote_initiative

      within ".view-side" do
        expect(page).to have_content("1\nSIGNATURE")
        click_button "Sign"
        expect(page).to have_content("0\nSIGNATURE")
      end
    end
  end

  def vote_initiative(user_name: nil)
    visit decidim_initiatives.initiative_path(initiative)

    within ".view-side" do
      expect(page).to have_content("0\nSIGNATURE")
      click_button "Sign"
    end

    click_button user_name if user_name.present?

    within ".view-side" do
      expect(page).to have_content("1\nSIGNATURE")
    end
  end
end
