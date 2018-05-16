# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SearchableResource do
    subject { searchable_rsrc }

    let(:searchable_rsrc) { build(:searchable_resource, locale: "en") }

    it { is_expected.to be_valid }

    describe "uniqueness" do
      context "when indexing different searchable_rsrcs" do
        before { subject.save! }

        context "when resource is different" do
          let(:other_rsrc) do
            create(:searchable_resource, locale: subject.locale, resource: build(:dummy_resource))
          end

          it "other_rsrc must be valid" do
            expect(other_rsrc).to be_valid
            expect(other_rsrc).to be_persisted
          end
        end

        context "when locale is different" do
          let(:other_rsrc) do
            create(:searchable_resource, locale: "ca", resource: subject.resource)
          end

          it "other_rsrc must be valid" do
            expect(other_rsrc).to be_valid
            expect(other_rsrc).to be_persisted
          end
        end

        context "when resource and locale are the same" do
          it "other_rsrc must NOT be valid" do
            expect do
              create(:searchable_resource, locale: subject.locale, resource: subject.resource)
            end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Locale has already been taken")
          end
        end
      end
    end
  end
end
