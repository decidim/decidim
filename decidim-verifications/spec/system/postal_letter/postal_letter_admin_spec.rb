# frozen_string_literal: true

require "spec_helper"

describe "Postal letter management", type: :system do
  let(:organization) do
    create(:organization, available_authorizations: ["postal_letter"])
  end

  let(:admin) { create(:user, :confirmed, :admin, organization:) }
  let(:user) { create :user, :confirmed, organization: }
  let(:user2) { create :user, :confirmed, organization: }

  let!(:letter_not_sent) do
    create(
      :authorization,
      :pending,
      user:,
      name: "postal_letter",
      verification_metadata: {
        pending_verification_code: "123456",
        address: "C/ Rua del Percebe, 13"
      }
    )
  end

  let!(:letter_sent) do
    create(
      :authorization,
      :pending,
      user: user2,
      name: "postal_letter",
      verification_metadata: {
        verification_code: "123456",
        letter_sent_at: 1.day.ago
      }
    )
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_postal_letter.root_path
  end

  it "shows the list of pending verifications" do
    expect(page).to have_selector("table tbody tr", count: 2)

    within "table tbody" do
      within "tr", text: letter_not_sent.user.name do
        expect(page).to have_selector("td", text: letter_not_sent.verification_metadata["address"])
        expect(page).to have_selector("td", text: letter_not_sent.verification_metadata["pending_verification_code"])
      end

      within "tr", text: letter_sent.user.name do
        expect(page).to have_selector("td", text: letter_sent.verification_metadata["verification_code"])
        expect(page).to have_selector("td", text: letter_sent.verification_metadata["address"])
      end
    end
  end

  it "marks letters as sent" do
    within "table tbody tr", text: letter_not_sent.user.name do
      find("a.action-icon--verify").click
    end

    expect(page).to have_content("Letter successfully marked as sent")

    within "table tbody tr", text: letter_not_sent.user.name do
      expect(page).not_to have_selector("td a.action-icon--verify")
      expect(page).to have_selector("td", text: %r{\d+/\d+/\d+ \d+:\d+})
    end
  end
end
