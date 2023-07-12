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

    if Decidim.redesign_active
      within "#floating-helper-tip" do
        click_button
      end
    end

    within "#floating-helper-block" do
      expect(page).to have_content("Some relevant help")
      if Decidim.redesign_active
        click_button
      else
        find(".floating-helper__content-close").click
      end
    end

    visit current_path

    expect(page).not_to have_content("Some relevant help")

    if Decidim.redesign_active
      within "#floating-helper-tip" do
        click_button
      end
    else
      find(".floating-helper__text").click
    end

    within "#floating-helper-block" do
      expect(page).to have_css("p", text: "Some relevant help")
    end
  end
end
