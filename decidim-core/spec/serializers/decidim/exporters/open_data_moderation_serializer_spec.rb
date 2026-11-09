# frozen_string_literal: true

require "spec_helper"

module Decidim::Exporters
  describe OpenDataModerationSerializer do
    subject { described_class.new(resource) }

    let(:resource) { create(:moderation, :hidden, reportable:) }
    let(:reportable) { create(:dummy_resource) }
    let(:serialized) { subject.serialize }

    describe "#serialize" do
      context "when the reportable can be resolved" do
        it "includes the reported url" do
          expect(serialized).to include(reported_url: reportable.reported_content_url)
        end

        it "includes the moderation data" do
          expect(serialized).to include(
            id: resource.id,
            report_count: resource.report_count,
            reportable_type: resource.decidim_reportable_type,
            reportable_id: resource.decidim_reportable_id
          )
        end
      end

      # `belongs_to :reportable` is polymorphic, so the reference cannot be
      # enforced by the database. Reportables such as proposals and meetings are
      # also soft-deletable without `with_deleted` here, so moving one to the
      # trash is enough to reach this state.
      context "when the reportable no longer exists" do
        before do
          reportable.destroy!
          resource.reload
        end

        it "does not raise" do
          expect { serialized }.not_to raise_error
        end

        it "serializes the reported url as nil" do
          expect(serialized).to include(reported_url: nil)
        end

        it "still serializes the rest of the record" do
          expect(serialized).to include(
            id: resource.id,
            reportable_type: resource.decidim_reportable_type,
            reportable_id: resource.decidim_reportable_id
          )
        end
      end

      # Trashing a component does not trash its contents, so the resource
      # survives with an unresolvable component. `ResourceLocatorPresenter`
      # would then hand the resource itself to `EngineRouter.main_proxy`, which
      # calls `mounted_engine` on it.
      context "when the component of the reportable was deleted" do
        before do
          reportable.component.destroy
          resource.reload
        end

        it "does not raise" do
          expect { serialized }.not_to raise_error
        end

        it "serializes the reported url as nil" do
          expect(serialized).to include(reported_url: nil)
        end
      end
    end
  end
end
