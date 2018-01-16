# frozen_string_literal: true
require "spec_helper"

describe "Explore debates", type: :feature do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let(:current_feature) { create :feature, participatory_space: participatory_process, manifest_name: "debates" }
  let(:debates_count) { 5 }
  let!(:debates) do
    create_list(
      :debate,
      debates_count,
      feature: current_feature,
      start_time: DateTime.new(2016, 12, 13, 14, 15),
      end_time: DateTime.new(2016, 12, 13, 16, 17)
    )
  end

  before do
    switch_to_host(organization.host)
    visit path
  end

  context "index" do
    let(:path) { decidim_participatory_process_debates.debates_path(participatory_process_slug: participatory_process.slug, feature_id: current_feature.id) }

    it "shows all debates for the given process" do
      expect(page).to have_selector("article.card", count: debates_count)

      debates.each do |debate|
        expect(page).to have_content(translated(debate.title))
      end
    end
  end

  context "show" do
    let(:path) { decidim_participatory_process_debates.debate_path(id: debate.id, participatory_process_slug: participatory_process.slug, feature_id: current_feature.id) }
    let(:debates_count) { 1 }
    let(:debate) { debates.first }

    it "shows all debate info" do
      expect(page).to have_i18n_content(debate.title)
      expect(page).to have_i18n_content(debate.description)
      expect(page).to have_i18n_content(debate.instructions)

      within ".section.view-side" do
        expect(page).to have_content(13)
        expect(page).to have_content(/December/i)
        expect(page).to have_content("14:15 - 16:17")
      end
    end

    context "without category" do
      it "does not show any tag" do
        expect(page).not_to have_selector("ul.tags.tags--debate")
      end
    end

    context "with a category" do
      let(:debate) do
        debate = debates.first
        debate.category = create :category, participatory_space: participatory_process
        debate.save
        debate
      end

      it "shows tags for category" do
        expect(page).to have_selector("ul.tags.tags--debate")

        within "ul.tags.tags--debate" do
          expect(page).to have_content(translated(debate.category.name))
        end
      end
    end
  end
end
