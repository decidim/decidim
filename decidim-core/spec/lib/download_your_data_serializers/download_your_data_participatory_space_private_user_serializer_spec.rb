# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataSerializers::DownloadYourDataParticipatorySpacePrivateUserSerializer do
    subject { described_class.new(resource) }
    let(:resource) { build(:participatory_space_private_user) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the privatable to" do
        expect(serialized[:privatable_to]).to(
          include(id: resource.privatable_to_id)
        )
        expect(serialized[:privatable_to]).to(
          include(type: resource.privatable_to_type)
        )
        expect(serialized[:privatable_to]).to(
          include(title: resource.privatable_to.title)
        )
        expect(serialized[:privatable_to]).to(
          include(slug: resource.privatable_to.slug)
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
