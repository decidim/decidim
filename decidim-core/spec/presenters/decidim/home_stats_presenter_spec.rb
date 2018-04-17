# frozen_string_literal: true

require "spec_helper"
require "decidim/assemblies/test/factories"

module Decidim
  describe HomeStatsPresenter do
    subject { described_class.new(organization: organization) }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:process) { create(:participatory_process, :published, organization: organization) }
    let!(:assembly) { create(:assembly, :published, organization: organization) }
    let!(:process_component) { create :component, participatory_space: process }
    let!(:assembly_component) { create :component, participatory_space: assembly }

    around do |example|
      Decidim.stats.register :foo, priority: StatsRegistry::HIGH_PRIORITY, &proc { 10 }
      Decidim.stats.register :bar, priority: StatsRegistry::MEDIUM_PRIORITY, &proc { 20 }
      Decidim.stats.register :baz, priority: StatsRegistry::LOW_PRIORITY, &proc { 30 }

      example.run

      Decidim.stats.stats.reject! { |s| s[:name] == :baz }
      Decidim.stats.stats.reject! { |s| s[:name] == :bar }
      Decidim.stats.stats.reject! { |s| s[:name] == :foo }
    end

    before do
      manifests = Decidim.component_manifests.select { |manifest| manifest.name == :dummy }
      allow(Decidim).to receive(:component_manifests).and_return(manifests)
    end

    describe "#highlighted" do
      it "renders a collection of high priority stats including users and proceses" do
        a =
          "<div class=\"home-pam__highlight\">" \
            "<div class=\"home-pam__data\">" \
              "<h4 class=\"home-pam__title\">Participants</h4>" \
              "<span class=\"home-pam__number users_count\"> 1</span>" \
            "</div>" \
            "<div class=\"home-pam__data\">" \
              "<h4 class=\"home-pam__title\">Processes</h4>" \
              "<span class=\"home-pam__number processes_count\"> 1</span>" \
            "</div>" \
          "</div>" \
          "<div class=\"home-pam__highlight\">" \
            "<div class=\"home-pam__data\">" \
              "<h4 class=\"home-pam__title\">Assemblies</h4>" \
              "<span class=\"home-pam__number assemblies_count\"> 1</span>" \
            "</div>" \
            "<div class=\"home-pam__data\">" \
              "<h4 class=\"home-pam__title\">Foo</h4>" \
              "<span class=\"home-pam__number foo\"> 10</span>" \
            "</div>" \
          "</div>" \
          "<div class=\"home-pam__highlight\">" \
            "<div class=\"home-pam__data\">" \
              "<h4 class=\"home-pam__title\">Dummies high</h4>" \
              "<span class=\"home-pam__number dummies_count_high\"> 20</span>" \
            "</div>" \
          "</div>"
        expect(subject.highlighted).to eq(a)
      end
    end

    describe "#not_highlighted" do
      it "renders a collection of medium priority stats" do
        expect(subject.not_highlighted).to eq(
          "<div class=\"home-pam__lowlight\">" \
            "<div class=\"home-pam__data\">" \
              "<h4 class=\"home-pam__title\">Bar</h4>" \
              "<span class=\"home-pam__number bar\"> 20</span>" \
            "</div>" \
            "<div class=\"home-pam__data\">" \
              "<h4 class=\"home-pam__title\">Dummies medium</h4>" \
              "<span class=\"home-pam__number dummies_count_medium\"> 200</span>" \
            "</div>" \
            "<div class=\"home-pam__data\">" \
              "&nbsp;" \
            "</div>" \
          "</div>"
        )
      end
    end
  end
end
