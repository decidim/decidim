# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Votings::VotingPresenter do
    subject { described_class.new(voting) }

    let!(:voting) { create(:voting) }
    let(:organization_host) { voting.organization.host }

    describe "when no images were uploaded" do
      before do
        voting.introductory_image.purge
        voting.banner_image.purge
      end

      it "return nil for introductory_image_url" do
        expect(subject.introductory_image_url).to be_nil
      end

      it "return nil for banner_image_url" do
        expect(subject.banner_image_url).to be_nil
      end
    end

    describe "when images are attached" do
      it "resolves introductory_image_url" do
        expect(subject.introductory_image_url).to eq("http://#{organization_host}:#{Capybara.server_port}#{voting.attached_uploader(:introductory_image).path}")
      end

      it "resolves banner_image_url" do
        expect(subject.banner_image_url).to eq("http://#{organization_host}:#{Capybara.server_port}#{voting.attached_uploader(:banner_image).path}")
      end
    end
  end
end
