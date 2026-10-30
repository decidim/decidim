# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Area do
    subject(:area) { build(:area, area_type:, organization:) }

    let(:organization) { create(:organization) }
    let(:area_type) { create(:area_type, organization:) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    describe "reciprocal associations" do
      subject(:area) { create(:area, organization:) }

      let(:other_organization) { create(:organization) }
      let(:other_area) { create(:area, organization: other_organization) }

      shared_examples "area reciprocal association" do |association, owner, cascaded: true|
        before do
          record
          other_record
        end

        it "only includes the records of its own area" do
          expect(area.public_send(association)).to contain_exactly(record)
        end

        it "does not include the records of another area, even when it is in another organization" do
          expect(area.public_send(association)).not_to include(other_record)
        end

        it "points back to the area from the records loaded through the association" do
          expect(area.public_send(association).first.public_send(owner)).to eq(area)
        end

        if cascaded
          it "deletes the records when the area is destroyed" do
            area.destroy

            expect(record.class.where(id: record.id)).to be_empty
            expect(other_record.class.where(id: other_record.id)).to exist
          end
        else
          it "keeps the records when the area is destroyed, as they are not cascaded" do
            area.destroy

            expect(record.class.where(id: record.id)).to exist
            expect(other_record.class.where(id: other_record.id)).to exist
          end
        end
      end

      context "with action logs" do
        let(:record) { create(:action_log, organization:, area:, user: create(:user, organization:)) }
        let(:other_record) { create(:action_log, organization: other_organization, area: other_area, user: create(:user, organization: other_organization)) }

        it_behaves_like "area reciprocal association", :action_logs, :area, cascaded: false
      end
    end

    context "with two areas with the same name, type and organization" do
      context "when no area_type is present" do
        let!(:existing_area) { create(:area, name: area.name, area_type:, organization:) }

        it { is_expected.to be_invalid }
      end

      context "when no area_type present" do
        let(:area_type) { nil }
        let!(:existing_area) { create(:area, name: area.name, organization:) }

        it { is_expected.to be_invalid }
      end
    end

    context "with two areas with the same name and organization but different types" do
      let!(:existing_area) { create(:area, name: area.name, organization:) }

      it { is_expected.to be_valid }
    end

    context "with two areas with the same name in different organizations" do
      let!(:existing_area) { create(:area, name: area.name) }

      it { is_expected.to be_valid }
    end

    context "without name" do
      before do
        area.name = {}
      end

      it { is_expected.to be_invalid }
    end

    context "without organization" do
      before do
        area.organization = nil
      end

      it { is_expected.to be_invalid }
    end
  end
end
