shared_examples "showing the design page" do |title, content|
  it "shows the page" do
    within ".design__navigation" do
      click_link title
    end

    within "main" do
      within "h1" do
        expect(page).to have_content(title)
      end
      expect(page).to have_content(content)
    end
  end
end
