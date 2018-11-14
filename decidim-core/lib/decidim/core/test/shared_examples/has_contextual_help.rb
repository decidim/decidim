# frozen_string_literal: true

shared_examples "shows contextual help" do
  before do
    Decidim::ContextualHelpRepository.new(organization).set(
      manifest_name,
      en: "<p>Some relevant help</p>"
    )
  end

  it "shows the contextual help on the root path" do
    visit index_path

    expect(page).to have_no_content("Some relevant help")

    find(".floating-helper__text").click

    within ".floating-helper__content" do
      expect(page).to have_css("p", text: "Some relevant help")
    end
  end
end
