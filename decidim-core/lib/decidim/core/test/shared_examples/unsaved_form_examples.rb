# frozen_string_literal: true

shared_examples "a form with unsaved changes" do |form_selector, field, exit_link|
  it "asks for confirmation before leaving the form" do
    within form_selector do
      fill_in field, with: "Unsaved changes"
      click_on exit_link
    end

    expect(page).to have_css("#confirm-modal", visible: :visible, text: I18n.t("decidim.shared.confirm_unload"))
  end

  it "keeps the unsaved changes when the confirmation is dismissed" do
    within form_selector do
      fill_in field, with: "Unsaved changes"
      click_on exit_link
    end
    dismiss_confirm

    expect(page).to have_css(form_selector)
    expect(page).to have_field(field, with: "Unsaved changes")
  end

  it "leaves the form when the confirmation is accepted" do
    within form_selector do
      fill_in field, with: "Unsaved changes"
      click_on exit_link
    end
    accept_confirm

    expect(page).to have_no_css(form_selector)
  end
end
