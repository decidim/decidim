# frozen_string_literal: true

require "spec_helper"

describe Decidim::Accountability::Admin::UpdateTemplateTexts do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :accountability_feature, participatory_space: participatory_process }

  let(:template_texts) { create :template_texts, feature: current_feature }

  let(:intro) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:categories_label) do
    Decidim::Faker::Localized.word
  end
  let(:subcategories_label) do
    Decidim::Faker::Localized.word
  end
  let(:heading_parent_level_results) do
    Decidim::Faker::Localized.word
  end
  let(:heading_leaf_level_results) do
    Decidim::Faker::Localized.word
  end

  let(:form) do
    double(
      :invalid? => invalid,
      intro: intro,
      categories_label: categories_label,
      subcategories_label: subcategories_label,
      heading_parent_level_results: heading_parent_level_results,
      heading_leaf_level_results: heading_leaf_level_results
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form, template_texts) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "sets the intro" do
      subject.call
      expect(translated template_texts.intro).to eq intro[:en]
    end

    it "sets the categories_label" do
      subject.call
      expect(translated template_texts.categories_label).to eq categories_label[:en]
    end

    it "sets the subcategories_label" do
      subject.call
      expect(translated template_texts.subcategories_label).to eq subcategories_label[:en]
    end

    it "sets the heading_parent_level_results" do
      subject.call
      expect(translated template_texts.heading_parent_level_results).to eq heading_parent_level_results[:en]
    end

    it "sets the heading_leaf_level_results" do
      subject.call
      expect(translated template_texts.heading_leaf_level_results).to eq heading_leaf_level_results[:en]
    end
  end
end
