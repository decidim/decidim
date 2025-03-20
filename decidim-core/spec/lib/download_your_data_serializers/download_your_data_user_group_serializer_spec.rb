# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataSerializers::DownloadYourDataUserGroupSerializer do
    subject { described_class.new(resource) }
    let(:resource) { create(:user_group) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the name" do
        expect(serialized).to include(name: resource.name)
      end

      it "includes the document number" do
        expect(serialized).to include(document_number: resource.document_number)
      end

      it "includes the phone" do
        expect(serialized).to include(phone: resource.phone)
      end

      it "includes the verified at" do
        expect(serialized).to include(verified_at: resource.verified_at)
      end
    end
  end
end
