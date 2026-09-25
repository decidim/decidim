# frozen_string_literal: true

shared_examples "a form with unsaved changes" do |form_selector, field, exit_link|
  it "asks for confirmation before leaving the form" do
    within form_selector do
      fill_in field, with: "Unsaved changes"
      click_on exit_link
    end

    expect(page).to have_css("#confirm-modal", visible: :visible, text: I18n.t("decidim.shared.confirm_unload"))
  end
end
