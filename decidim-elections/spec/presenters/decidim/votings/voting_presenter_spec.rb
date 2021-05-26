# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Votings::VotingPresenter do
    subject { described_class.new(voting) }

    let!(:voting) { create(:voting) }
    let(:organization_host) { voting.organization.host }

    describe "when no images were uploaded" do
      before do
        voting.update!(introductory_image: nil, banner_image: nil)
      end

      it "return nil for introductory_image_url" do
        expect(subject.introductory_image_url).to be_nil
      end

      it "return nil for banner_image_url" do
        expect(subject.banner_image_url).to be_nil
      end
    end

    describe "when images are stored in the local filesystem" do
      it "resolves introductory_image_url" do
        expect(subject.introductory_image_url).to eq("http://#{organization_host}#{voting.introductory_image_url}")
      end

      it "resolves banner_image_url" do
        expect(subject.banner_image_url).to eq("http://#{organization_host}#{voting.banner_image_url}")
      end
    end

    describe "when images are stored in a cloud service" do
      it "resolves introductory_image_url" do
        avoid_the_use_of_file_storage_specific_methods(:introductory_image)
        expect(subject.introductory_image_url).to eq("http://#{organization_host}#{voting.introductory_image_url}")
      end

      it "resolves banner_image_url" do
        avoid_the_use_of_file_storage_specific_methods(:banner_image)
        expect(subject.banner_image_url).to eq("http://#{organization_host}#{voting.banner_image_url}")
      end

      def avoid_the_use_of_file_storage_specific_methods(uploader_name)
        expect(voting.send(uploader_name).file).not_to receive(:file)
      end
    end
  end
end
