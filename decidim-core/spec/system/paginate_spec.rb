# frozen_string_literal: true

require "spec_helper"

describe "Paginate specs" do
  let(:organization) { create(:organization) }
  let(:component) { create(:component, :published, organization:) }
  let(:commentable) { create(:dummy_resource, component:) }
  let(:comment) { create(:comment, commentable:) }

  before do
    switch_to_host organization.host
    visit decidim.root_path
  end

  shared_examples "list pagination" do |per_page|
    let!(:action_logs) { create_list(:action_log, per_page + 1, created_at: 1.day.ago, action: "create", visibility: "public-only", resource: comment, organization:) }

    it "shows the paginator" do
      visit decidim.last_activities_path(per_page:)

      expect(page).to have_content("Results per page:")
      within("details") do
        within("summary") do
          expect(page).to have_content(per_page.to_s)
        end

        within("ul", visible: :all) do
          expect(page).to have_link("25", href: decidim.last_activities_path(per_page: 25), visible: :all)
          expect(page).to have_link("50", href: decidim.last_activities_path(per_page: 50), visible: :all)
          expect(page).to have_link("100", href: decidim.last_activities_path(per_page: 100), visible: :all)
        end
      end
    end
  end

  it_behaves_like "list pagination", 25
  it_behaves_like "list pagination", 50
  # it_behaves_like "list pagination", 100
end
