# frozen_string_literal: true

require "spec_helper"

module Decidim::Exporters
  describe OpenDataUserSerializer do
    subject { described_class.new(resource) }

    let(:organization) { create(:organization) }
    let(:serialized) { subject.serialize }
    let(:resource) { create(:user, :confirmed, organization:) }

    describe "#serialize" do
      describe "avatar_url" do
        before do
          allow(ActiveStorage::Current).to receive(:url_options).and_return({})
        end

        it "includes the avatar_url" do
          expect(serialized[:avatar_url]).to match(%r{\Ahttp://})
        end

        context "when the asset is already processed" do
          before do
            thumb = resource.attached_uploader(:avatar).variant(:thumb)
            thumb.processed
          end

          it "includes the avatar_url" do
            expect(serialized[:avatar_url]).to match(%r{\Ahttp://})
          end
        end
      end
    end
  end
end
