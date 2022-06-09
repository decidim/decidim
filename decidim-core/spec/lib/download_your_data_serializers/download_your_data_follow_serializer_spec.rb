# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataSerializers::DownloadYourDataFollowSerializer do
    subject { described_class.new(resource) }
    let(:resource) { build(:follow) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the followable" do
        expect(serialized[:followable]).to(
          include(id: resource.decidim_followable_id)
        )
        expect(serialized[:followable]).to(
          include(type: resource.decidim_followable_type)
        )
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
