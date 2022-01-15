# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::AreaPresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { area.id }
  let!(:area) { create :area }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  describe "#present" do
    context "when the area is found" do
      let(:title) { area.name["en"] }

      it "shows the area title" do
        expect(subject.present).to eq title
      end
    end

    context "when the area isn't found" do
      let(:value) { area.id + 1 }

      it "shows a string explaining the problem" do
        expect(subject.present).to eq "The area was not found on the database (ID: #{value})"
      end
    end
  end
end
