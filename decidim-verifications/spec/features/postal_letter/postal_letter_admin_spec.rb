# frozen_string_literal: true

require "spec_helper"

describe "Postal letter management", type: :feature do
  let(:organization) do
    create(:organization, available_authorizations: ["postal_letter"])
  end

  let(:admin) { create(:user, :confirmed, :admin, organization: organization) }

  let!(:letter_not_sent) do
    create(
      :authorization,
      :pending,
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
      name: "postal_letter",
      verification_metadata: { verification_code: "123456" }
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
end
