# frozen_string_literal: true

require "spec_helper"
require "./db/data/20260113140600_reindex_results"

describe ReindexResults do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    context "when the component is published" do
      let(:component) { create(:accountability_component, published_at: Time.zone.now) }

      context "and there are results" do
        let!(:results) { create_list(:result, 2, component:) }

        it "those are added to index" do
          Decidim::SearchableResource.delete_all

          expect(Decidim::SearchableResource.where(resource: results)).to be_empty
          perform_enqueued_jobs { migrator.migrate(:up) }
          expect(Decidim::SearchableResource.where(resource: results)).not_to be_empty
          # 3 languages multiplied by 2 results
          expect(Decidim::SearchableResource.where(resource: results).count).to eq(6)
        end
      end

      context "and there are deleted results" do
        let!(:results) { create_list(:result, 2, component:) }

        it "those are added to index" do
          results.map(&:destroy)
          Decidim::SearchableResource.delete_all

          expect(Decidim::SearchableResource.where(resource: results)).to be_empty
          perform_enqueued_jobs { migrator.migrate(:up) }
          expect(Decidim::SearchableResource.where(resource: results)).to be_empty
        end
      end

      context "and there are no results" do
        let!(:results) { [] }

        it "does not reindex the results" do
          Decidim::SearchableResource.delete_all

          expect(Decidim::SearchableResource.where(resource: results)).to be_empty
          perform_enqueued_jobs { migrator.migrate(:up) }
          expect(Decidim::SearchableResource.where(resource: results)).to be_empty
        end
      end
    end

    context "when the component is not published" do
      let(:component) { create(:accountability_component, published_at: nil) }
      let!(:results) { create_list(:result, 2, component:) }

      it "does not reindex the results" do
        Decidim::SearchableResource.delete_all

        expect(Decidim::SearchableResource.where(resource: results)).to be_empty
        perform_enqueued_jobs { migrator.migrate(:up) }
        expect(Decidim::SearchableResource.where(resource: results)).to be_empty
      end
    end

    context "when the component is deleted" do
      let(:component) { create(:accountability_component, published_at: Time.zone.now, deleted_at: Time.zone.now) }
      let!(:results) { create_list(:result, 2, component:) }

      it "does not reindex the results" do
        Decidim::SearchableResource.delete_all

        expect(Decidim::SearchableResource.where(resource: results)).to be_empty
        perform_enqueued_jobs { migrator.migrate(:up) }
        expect(Decidim::SearchableResource.where(resource: results)).to be_empty
      end
    end
  end
end
