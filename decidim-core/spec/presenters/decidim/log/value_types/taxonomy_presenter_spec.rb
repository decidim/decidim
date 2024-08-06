# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::TaxonomyPresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { taxonomy.id }
  let!(:taxonomy) { create(:taxonomy) }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  describe "#present" do
    context "when the taxonomy is found" do
      let(:title) { taxonomy.name["en"] }

      it "shows the taxonomy title" do
        expect(subject.present).to eq title
      end
    end

    context "when the taxonomy is not found" do
      let(:value) { taxonomy.id + 1 }

      it "shows a string explaining the problem" do
        expect(subject.present).to eq "The taxonomy was not found on the database (ID: #{value})"
      end
    end
  end
end
