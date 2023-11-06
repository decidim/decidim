# frozen_string_literal: true

shared_examples "shows contextual help" do
  before do
    Decidim::ContextualHelpSection.set_content(
      organization,
      manifest_name,
      en: "<p>Some relevant help</p>"
    )
  end

  it "shows the contextual help on the root path on first visit, hides it on subsequent ones" do
    visit index_path

    within "#floating-helper-tip" do
      click_button
    end

    within "#floating-helper-block" do
      expect(page).to have_content("Some relevant help")
      click_button
    end

    visit current_path

    expect(page).not_to have_content("Some relevant help")

    within "#floating-helper-tip" do
      click_button
    end

    within "#floating-helper-block" do
      expect(page).to have_css("p", text: "Some relevant help")
    end
  end
end
