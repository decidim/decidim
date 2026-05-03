# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataSerializers::DownloadYourDataMemberSerializer do
    subject { described_class.new(resource) }
    let(:resource) { build(:member) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the participatory space" do
        expect(serialized[:participatory_space]).to(
          include(id: resource.participatory_space_id)
        )
        expect(serialized[:participatory_space]).to(
          include(type: resource.participatory_space_type)
        )
        expect(serialized[:participatory_space]).to(
          include(title: resource.participatory_space.title)
        )
        expect(serialized[:participatory_space]).to(
          include(slug: resource.participatory_space.slug)
        )
      end

      it "includes the created at" do
        expect(serialized).to include(created_at: resource.created_at)
      end

      it "includes the updated at" do
        expect(serialized).to include(updated_at: resource.updated_at)
      end

      it "includes the role" do
        expect(serialized).to include(role: resource.role)
      end

      it "includes the published" do
        expect(serialized).to include(published: resource.published)
      end
    end
  end
end
