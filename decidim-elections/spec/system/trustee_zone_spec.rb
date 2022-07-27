# frozen_string_literal: true

require "spec_helper"

describe "Trustee zone", type: :system do
  let(:organization) { create(:organization, :secure_context) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:trustee) { create(:trustee, user:, public_key:, organization:) }
  let(:public_key) { nil }

  before do
    trustee
    switch_to_secure_context_host
    login_as user, scope: :user
  end

  context "when the user name exists in this organization", download: true do
    let!(:other_trustee) { create(:trustee, :with_public_key, name: user.name, organization: user.organization) }

    it "can't generate identification keys" do
      visit decidim.decidim_elections_trustee_zone_path

      expect(page).to have_content("Generate identification keys")

      click_button "Generate identification keys"

      wait_for_download

      expect(download_content).to have_content('"alg":"RS256"')

      find("label", text: "Submit").click

      expect(page).to have_content("Name has already been taken")
    end
  end

  it "can access to the trustee zone" do
    visit decidim.account_path

    expect(page).to have_content("Trustee zone")

    click_link "Trustee zone"

    expect(page).to have_content("Trustee identification keys")
  end

  it "can generate their identification keys", download: true do
    visit decidim.decidim_elections_trustee_zone_path

    expect(page).to have_content("Generate identification keys")

    click_button "Generate identification keys"

    wait_for_download

    expect(download_content).to have_content('"alg":"RS256"')

    find("label", text: "Submit").click

    expect(page).to have_content("Your identification public key was successfully stored.")
    expect(page).to have_content("Upload your identification keys")

    attach_file(downloads.first) do
      click_button "Upload your identification keys"
    end

    expect(page).not_to have_content("Upload your identification keys")
    expect(page).not_to have_content("Trustee identification keys")
  end

  context "when the trustee already has a public key" do
    let(:public_key) { File.read(Decidim::Dev.asset("public_key.jwk")) }

    it "can upload their identification keys" do
      visit decidim.decidim_elections_trustee_zone_path

      expect(page).not_to have_content("Generate identification keys")
      expect(page).to have_content("Upload your identification keys")

      attach_file(Decidim::Dev.asset("private_key.jwk")) do
        click_button "Upload your identification keys"
      end

      expect(page).not_to have_content("Upload your identification keys")
    end

    {
      "a different private key" => "private_key2.jwk",
      "a public_key" => "public_key.jwk",
      "an image" => "city.jpeg"
    }.each do |description, filename|
      it "can't upload #{description}" do
        visit decidim.decidim_elections_trustee_zone_path

        expect(page).to have_content("Upload your identification keys")

        accept_alert do
          attach_file(Decidim::Dev.asset(filename)) do
            click_button "Upload your identification keys"
          end
        end

        expect(page).to have_content("Upload your identification keys")
      end
    end
  end

  context "when the user is not a trustee" do
    let(:trustee) { create(:trustee) }

    it "can't access to the trustee zone" do
      visit decidim.account_path

      expect(page).not_to have_content("Trustee zone")

      visit decidim.decidim_elections_trustee_zone_path

      expect(page).to have_content("You are not authorized to perform this action")

      expect(page).to have_current_path(decidim.root_path)
    end
  end

  context "when the bulletin_board is not configured" do
    before do
      allow(Decidim::Elections.bulletin_board).to receive(:configured?).and_return(false)
      trustee
      login_as user, scope: :user
    end

    it "notifies that it is not configured" do
      visit decidim.account_path

      expect(page).to have_content("Trustee zone")

      visit decidim.decidim_elections_trustee_zone_path

      expect(page).to have_content("Sorry, the Bulletin Board is not configured yet")
    end
  end
end
