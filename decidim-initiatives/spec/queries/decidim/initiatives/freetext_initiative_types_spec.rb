# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe FreetextInitiativeTypes do
      let!(:organization) { create(:organization) }
      let!(:initiative_types) do
        %w(Aaaa Aabb Bbbb).map do |title|
          create(:initiatives_type,
                 title: Decidim::Faker::Localized.literal(title),
                 description: Decidim::Faker::Localized.sentence(word_count: 25),
                 organization:)
        end
      end

      context "when find one result" do
        subject { described_class.new(organization, "en", "Bb") }

        it "Returns one result" do
          expect(subject.query.count).to eq(1)
        end
      end

      context "when find several results" do
        subject { described_class.new(organization, "en", "Aa") }

        it "Returs several results" do
          expect(subject.query.count).to eq(2)
        end
      end

      context "when don't find results" do
        subject { described_class.new(organization, "en", "Dd") }

        it "is empty" do
          expect(subject.query).to be_empty
        end
      end
    end
  end
end
