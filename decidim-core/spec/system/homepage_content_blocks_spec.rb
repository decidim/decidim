# frozen_string_literal: true

require "spec_helper"

describe "Homepage with content blocks" do
  let(:official_url) { "http://test.example.org" }
  let(:organization) { create(:organization, official_url:) }
  let!(:participatory_process) { create(:participatory_process, :promoted, organization:) }
  let!(:assembly) { create(:assembly, :promoted, organization:) }
  let!(:component) { create(:component, manifest_name: :meetings, organization:) }
  let!(:meeting) { create(:meeting, :published, component:) }

  before do
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :hero, weight: 1)
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :sub_hero, weight: 2)
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :how_to_participate, weight: 3)
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :stats, weight: 4)
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :footer_sub_hero, weight: 5)
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :highlighted_processes, weight: 6)
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :highlighted_assemblies, weight: 7)
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :upcoming_meetings, weight: 8)
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :html, weight: 9, settings: { html_content: { en: "<div class=\"custom-html\">Custom HTML Content</div>" } })

    switch_to_host(organization.host)
  end

  it "renders all content blocks on the homepage" do
    visit decidim.root_path

    expect(page).to have_css("section.hero__container")
    expect(page).to have_css("#sub_hero")
    expect(page).to have_css("#how_to_participate")
    expect(page).to have_css("#statistics")
    expect(page).to have_css("#footer_sub_hero")
    expect(page).to have_css("#highlighted-processes")
    expect(page).to have_css("#highlighted-assemblies")
    expect(page).to have_css("[id^=meetings]")
    expect(page).to have_css(".custom-html")
  end

  it "renders content blocks in the correct order by weight" do
    visit decidim.root_path

    hero_section = page.find("section.hero__container")
    sub_hero_section = page.find_by_id("sub_hero")
    how_to_participate_section = page.find_by_id("how_to_participate")
    stats_section = page.find_by_id("statistics")
    footer_sub_hero_section = page.find_by_id("footer_sub_hero")

    hero_position = hero_section.evaluate_script("this.getBoundingClientRect().top")
    sub_hero_position = sub_hero_section.evaluate_script("this.getBoundingClientRect().top")
    how_to_participate_position = how_to_participate_section.evaluate_script("this.getBoundingClientRect().top")
    stats_position = stats_section.evaluate_script("this.getBoundingClientRect().top")
    footer_sub_hero_position = footer_sub_hero_section.evaluate_script("this.getBoundingClientRect().top")

    expect(hero_position).to be < sub_hero_position
    expect(sub_hero_position).to be < how_to_participate_position
    expect(how_to_participate_position).to be < stats_position
    expect(stats_position).to be < footer_sub_hero_position
  end

  it "renders each content block with its corresponding cell content" do
    visit decidim.root_path

    expect(page).to have_css("section.hero__container")
    within "section.hero__container" do
      expect(page).to have_content("Welcome")
    end

    expect(page).to have_css("#how_to_participate")
    expect(page).to have_content("How do I take part in a process?")

    expect(page).to have_css("#statistics")
    expect(page).to have_content("Statistics")

    expect(page).to have_css("#footer_sub_hero")

    expect(page).to have_css("#highlighted-processes")
    expect(page).to have_css("#highlighted-assemblies")
    expect(page).to have_css("[id^=meetings]")

    expect(page).to have_css(".custom-html")
    expect(page).to have_content("Custom HTML Content")
  end
end
