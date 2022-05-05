# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataSerializers::DownloadYourDataIdentitySerializer do
    subject { described_class.new(resource) }
    let(:user) { create(:user) }
    let(:organization) { user&.organization }
    let(:provider) { "facebook" }
    let(:uid) { "123456" }
    let(:resource) { build(:identity, user: user, provider: provider, uid: uid, organization: organization) }

    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the provider" do
        expect(serialized).to include(provider: resource.provider)
      end

      it "includes the uid" do
        expect(serialized).to include(uid: resource.uid)
      end

      it "includes the user" do
        expect(serialized[:user]).to(
          include(id: resource.user.id)
        )
        expect(serialized[:user]).to(
          include(name: resource.user.name)
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
