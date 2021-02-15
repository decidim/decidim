# frozen_string_literal: true

require "spec_helper"

describe "ExternalDomainWarning", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { nil }
  let(:content) { { en: 'Hello world <a href="www.danger.com">Very nice link</a>' } }
  let!(:static_page) { create(:static_page, organization: organization, show_in_footer: true, allow_public_access: true, content: content) }

  it "shows warning when clicking link with an external link" do
    visit current_path
    click_link static_page_1.title["en"]
    click_link "Very nice link"
    expect.page(page).to have_content("External link warning")
  end
end
