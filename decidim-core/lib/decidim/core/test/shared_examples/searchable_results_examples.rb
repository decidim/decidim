# frozen_string_literal: true

shared_examples "searchable results" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "when searching for indexed searchables" do
    before do
      expect(searchables).not_to be_empty
      expect(term).not_to be_empty
    end

    it "contains these searchables" do
      fill_in "term", with: term
      find("input#term").native.send_keys :enter

      expect(page).to have_current_path decidim.search_path, ignore_query: true
      expect(page).to have_content(/results for the search: "#{term}"/i)
      expect(page).to have_selector(".filters__section")
      expect(page.find("#search-count .section-heading").text.to_i).to be_positive
    end

    it "finds content by hashtag" do
      if respond_to?(:hashtag)
        fill_in "term", with: hashtag
        find("input#term").native.send_keys :enter

        expect(page.find("#search-count .section-heading").text.to_i).to be_positive

        within "#results" do
          expect(page).to have_content(hashtag)
        end
      end
    end
  end
end
