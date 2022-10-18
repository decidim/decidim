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

    within "#floating-helper-block" do
      expect(page).to have_content("Some relevant help")
      find("button").click
    end

    visit current_path

    expect(page).to have_no_content("Some relevant help")

    find("#floating-helper-tip button").click

    within "#floating-helper-block" do
      expect(page).to have_css("p", text: "Some relevant help")
    end
  end
end
