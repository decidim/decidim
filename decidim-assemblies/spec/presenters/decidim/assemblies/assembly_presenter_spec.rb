# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Assemblies::AssemblyPresenter do
    subject { described_class.new(assembly) }

    let!(:assembly) { create(:assembly) }
    let(:organization_host) { assembly.organization.host }

    describe "when no images were uploaded" do
      before do
        assembly.update!(hero_image: nil, banner_image: nil)
      end

      it "return nil for hero_image_url" do
        expect(subject.hero_image_url).to be_nil
      end

      it "return nil for banner_image_url" do
        expect(subject.banner_image_url).to be_nil
      end
    end

    describe "when images are stored in the local filesystem" do
      it "resolves hero_image_url" do
        expect(subject.hero_image_url).to eq("http://#{organization_host}#{assembly.hero_image_url}")
      end

      it "resolves banner_image_url" do
        expect(subject.banner_image_url).to eq("http://#{organization_host}#{assembly.banner_image_url}")
      end
    end

    describe "when images are stored in a cloud service" do
      it "resolves hero_image_url" do
        avoid_the_use_of_file_storage_specific_methods(:hero_image)
        expect(subject.hero_image_url).to eq("http://#{organization_host}#{assembly.hero_image_url}")
      end

      it "resolves banner_image_url" do
        avoid_the_use_of_file_storage_specific_methods(:banner_image)
        expect(subject.banner_image_url).to eq("http://#{organization_host}#{assembly.banner_image_url}")
      end

      def avoid_the_use_of_file_storage_specific_methods(uploader_name)
        # we're avoiding the use of `assembly.hero_image.file.file` in
        expect(assembly.send(uploader_name).file).not_to receive(:file)
      end
    end
  end
end
