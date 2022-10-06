# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Assemblies::AssemblyPresenter do
    subject { described_class.new(assembly) }

    let!(:assembly) { create(:assembly) }
    let(:organization_host) { assembly.organization.host }

    describe "when no images were uploaded" do
      before do
        assembly.hero_image.purge
        assembly.banner_image.purge
      end

      it "return nil for hero_image_url" do
        expect(subject.hero_image_url).to be_nil
      end

      it "return nil for banner_image_url" do
        expect(subject.banner_image_url).to be_nil
      end
    end

    describe "when images are attached" do
      it "resolves hero_image_url" do
        expect(subject.hero_image_url).to eq("http://#{organization_host}:#{Capybara.server_port}#{assembly.attached_uploader(:hero_image).path}")
      end

      it "resolves banner_image_url" do
        expect(subject.banner_image_url).to eq("http://#{organization_host}:#{Capybara.server_port}#{assembly.attached_uploader(:banner_image).path}")
      end
    end
  end
end
