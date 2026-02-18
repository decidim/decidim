# frozen_string_literal: true

shared_examples "searchable results" do
  let(:organization) { create(:organization) }
  let(:search_input_selector) { "input#input-search" }

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
      find(search_input_selector).native.send_keys :enter

      expect(page).to have_current_path decidim.search_path, ignore_query: true
      expect(page).to have_content(%(results for the search: "#{term}"))
      expect(page).to have_css(".filter-search.filter-container")
      expect(page.find("#search-count h2").text.to_i).to be_positive
    end

    context "when moderation is involved" do
      it "not contains these searchables" do
        expect(searchables).not_to be_empty
        expect(term).not_to be_empty

        fill_in "term", with: term
        find(search_input_selector).native.send_keys :enter

        expect(page).to have_current_path decidim.search_path, ignore_query: true
        expect(page).to have_content(%(results for the search: "#{term}"))
        expect(page).to have_css(".filter-search.filter-container")
        expect(page.find("#search-count h2").text.to_i).to be_positive

        searchables.each do |searchable|
          next unless searchable.is_a?(Decidim::Reportable)

          create(:moderation, reportable: searchable, hidden_at: Time.current)
          # rubocop:disable Rails/SkipsModelValidations
          searchable.reload.touch
          # rubocop:enable Rails/SkipsModelValidations
        end

        visit decidim.root_path

        fill_in "term", with: term
        find(search_input_selector).native.send_keys :enter

        expect(page).to have_current_path decidim.search_path, ignore_query: true
        expect(page).to have_content(%(results for the search: "#{term}"))
        expect(page).to have_css(".filter-search.filter-container")
        expect(page.find("#search-count h2").text.to_i).not_to be_positive
      end
    end

    context "when participatory space is not visible" do
      shared_examples_for "no searches found" do
        it "not contains these searchables" do
          expect(searchables).not_to be_empty
          expect(term).not_to be_empty

          fill_in "term", with: term
          find(search_input_selector).native.send_keys :enter

          expect(page).to have_current_path decidim.search_path, ignore_query: true
          expect(page).to have_content(%(results for the search: "#{term}"))
          expect(page).to have_css(".filter-search.filter-container")
          expect(page.find("#search-count h2").text.to_i).not_to be_positive
        end
      end

      context "when participatory space is unpublished" do
        before do
          perform_enqueued_jobs { participatory_space.update!(published_at: nil) }
        end

        it_behaves_like "no searches found"
      end

      context "when participatory space is private" do
        before do
          perform_enqueued_jobs { participatory_space.update!(private_space: true) }
        end

        it_behaves_like "no searches found"
      end
    end
  end
end
