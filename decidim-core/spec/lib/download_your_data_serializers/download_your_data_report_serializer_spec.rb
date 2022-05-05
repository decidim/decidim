# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataSerializers::DownloadYourDataReportSerializer do
    subject { described_class.new(resource) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }
    let(:component) { create(:component, organization: organization) }
    let(:reportable) { create(:dummy_resource, component: component) }
    let(:moderation) { create(:moderation, reportable: reportable, participatory_space: component.participatory_space, report_count: 1) }
    let(:resource) { create(:report, moderation: moderation) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the moderation" do
        expect(serialized[:moderation]).to(
          include(id: resource.moderation.id)
        )

        expect(serialized[:moderation]).to(
          include(hidden_at: resource.moderation.hidden_at)
        )

        expect(serialized[:moderation]).to(
          include(created_at: resource.moderation.created_at)
        )

        expect(serialized[:moderation]).to(
          include(updated_at: resource.moderation.updated_at)
        )
      end

      it "includes the participatory space" do
        expect(serialized[:moderation][:participatory_space]).to(
          include(id: resource.moderation.decidim_participatory_space_id)
        )
        expect(serialized[:moderation][:participatory_space]).to(
          include(type: resource.moderation.decidim_participatory_space_type)
        )
        expect(serialized[:moderation][:participatory_space]).to(
          include(title: resource.moderation.participatory_space.title)
        )
      end

      it "includes the reportable element" do
        expect(serialized[:moderation][:reportable_element]).to(
          include(id: resource.moderation.decidim_reportable_id)
        )
        expect(serialized[:moderation][:reportable_element]).to(
          include(type: resource.moderation.decidim_reportable_type)
        )
      end

      it "includes the reason" do
        expect(serialized).to include(reason: resource.reason)
      end

      it "includes the details" do
        expect(serialized).to include(details: resource.details)
      end

      it "includes the created at" do
        expect(serialized).to include(created_at: resource.created_at)
      end

      it "includes the updated at" do
        expect(serialized).to include(updated_at: resource.updated_at)
      end
    end
  end
end
