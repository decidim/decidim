# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateAreaType do
    subject { described_class.new(area_type, form) }

    let(:organization) { create :organization }
    let(:area_type) { create :area_type, organization: organization }
    let(:name) { Decidim::Faker::Localized.literal("new name") }
    let(:plural) { Decidim::Faker::Localized.literal("new names") }

    let(:form) do
      double(
        invalid?: invalid,
        name: name,
        plural: plural
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      before do
        subject.call
        area_type.reload
      end

      it "updates the name of the scope" do
        expect(translated(area_type.name)).to eq("new name")
      end

      it "updates the plural of the scope" do
        expect(translated(area_type.plural)).to eq("new names")
      end
    end
  end
end
