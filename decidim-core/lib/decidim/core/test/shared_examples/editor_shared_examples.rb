# frozen_string_literal: true

shared_examples_for "has embedded video in description" do |description_attribute_name, count: 1|
  let(description_attribute_name) do
    {
      en: <<~HTML
        <p>Description</p>
        <div class="editor-content-videoEmbed" data-video-embed="#{iframe_src}">
          <div>
            <iframe src="#{iframe_src}" title="Test video" frameborder="0"></iframe>
          </div>
        </div>
      HTML
    }
  end
  let(:iframe_src) { "https://www.youtube.com/embed/f6JMgJAQ2tc" }
  let(:embedded_iframe_src) { "https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc" }
  let!(:cookie_warning) { "You need to enable all cookies in order to see this content" }

  context "when cookies are rejected" do
    before do
      click_on "Cookie settings"
      click_on "Accept only essential"
    end

    it "disables iframe" do
      expect(page).to have_text(cookie_warning)
      expect(page).to have_no_css("iframe")
    end
  end

  context "when cookies are accepted" do
    before do
      click_on "Cookie settings"
      click_on "Accept all"
    end

    it "shows the embedded iframe" do
      expect(page).to have_no_text(cookie_warning)
      expect(page).to have_css("iframe[src='#{embedded_iframe_src}']", count:)
    end
  end
end
