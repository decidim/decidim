# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SearchableResource do
    subject { searchable_resource }

    let(:searchable_resource) { build(:searchable_resource, locale: "en") }

    it { is_expected.to be_valid }

    describe "uniqueness" do
      context "when indexing different searchable_resources" do
        before { subject.save! }

        context "when resource is different" do
          let(:other_searchable) do
            resource = create(:dummy_resource)
            Decidim::SearchableResource.where(resource:)
          end

          it "other_searchable must be valid" do
            expect(other_searchable).to exist
          end
        end

        context "when locale is different" do
          let(:other_resource) do
            create(:searchable_resource, locale: "pt", resource: subject.resource)
          end

          it "other_resource must be valid" do
            expect(other_resource).to be_valid
            expect(other_resource).to be_persisted
          end
        end

        context "when resource and locale are the same" do
          it "other_resource must NOT be valid" do
            expect do
              create(:searchable_resource, locale: subject.locale, resource: subject.resource)
            end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Locale has already been taken")
          end
        end
      end
    end
  end
end
