# frozen_string_literal: true

shared_examples_for "has embedded video in description" do |description_attribute_name|
  let(description_attribute_name) { { en: %(Description <iframe class="ql-video" allowfullscreen="true" src="#{iframe_src}" frameborder="0"></iframe>) } }
  let(:iframe_src) { "http://www.example.org" }

  context "when cookies are rejected" do
    before do
      click_link "Cookie settings"
      click_button "Accept only essential"
    end

    it "disables iframe" do
      expect(page).to have_content("You need to enable all cookies in order to see this content")
      expect(page).not_to have_selector("iframe")
    end
  end

  context "when cookies are accepted" do
    before do
      click_link "Cookie settings"
      click_button "Accept all"
    end

    it "shows iframe" do
      expect(page).not_to have_content("You need to enable all cookies in order to see this content")
      expect(page).to have_selector("iframe", count: 1)
    end
  end
end
