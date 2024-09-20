# frozen_string_literal: true

require "spec_helper"

describe "Paginate specs" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :published, :with_steps, organization:) }
  let!(:proposal_component) { create(:proposal_component, participatory_space:) }

  before do
    switch_to_host organization.host
    visit decidim.root_path
  end

  shared_examples "list pagination" do |per_page|
    let!(:proposals) { create_list(:proposal, per_page + 1, component: proposal_component) }

    before do
      proposals.each { |s| s.update(published_at: Time.current) }
    end

    it "shows the paginator" do
      page_params = { filter: { with_resource_type: "Decidim::Proposals::Proposal" }, host: organization.host, port: Capybara.server_port }
      visit decidim.search_path(per_page:, **page_params)

      expect(page).to have_content("Results per page:")
      within("details") do
        within("summary") do
          expect(page).to have_content(per_page.to_s)
        end

        within("ul", visible: :all) do
          expect(page).to have_link("25", href: decidim.search_url(per_page: 25, **page_params), visible: :all)
          expect(page).to have_link("50", href: decidim.search_url(per_page: 50, **page_params), visible: :all)
          expect(page).to have_link("100", href: decidim.search_url(per_page: 100, **page_params), visible: :all)
        end
      end
    end
  end

  context "when per_page parameter is set" do
    it_behaves_like "list pagination", 25
    it_behaves_like "list pagination", 50
    it_behaves_like "list pagination", 100
  end

  context "when per_page parameter is not set" do
    let!(:proposals) { create_list(:proposal, 26, component: proposal_component) }

    before do
      proposals.each { |s| s.update(published_at: Time.current) }
    end

    it "shows the paginator" do
      page_params = { filter: { with_resource_type: "Decidim::Proposals::Proposal" }, host: organization.host, port: Capybara.server_port }
      visit decidim.search_path(**page_params)

      expect(page).to have_content("Results per page:")
      within("details") do
        within("summary") do
          expect(page).to have_content(25)
        end

        within("ul", visible: :all) do
          expect(page).to have_link("25", href: decidim.search_url(per_page: 25, **page_params), visible: :all)
          expect(page).to have_link("50", href: decidim.search_url(per_page: 50, **page_params), visible: :all)
          expect(page).to have_link("100", href: decidim.search_url(per_page: 100, **page_params), visible: :all)
        end
      end
    end
  end
end
