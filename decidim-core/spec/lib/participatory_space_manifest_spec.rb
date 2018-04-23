# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatorySpaceManifest do
    subject { described_class.new(name: manifest_name) }

    let(:manifest_name) { :my_space }

    describe "#context" do
      it "defines and caches contexts" do
        subject.context(:context1) do |context|
          context.layout = "layouts/context1"
        end

        subject.context(:context2) do |context|
          context.layout = "layouts/context2"
        end

        expect(subject.context(:context1).layout).to eq("layouts/context1")
        expect(subject.context(:context2).layout).to eq("layouts/context2")
      end
    end

    describe "#space_for(org)" do
      let(:organization) { create :organization }

      context "when the space does not exist in the DB" do
        it "creates a new space in the DB" do
          expect { subject.space_for(organization) }.to change(Decidim::ParticipatorySpace, :count).by(1)
        end
      end

      context "when the space already exists in the DB" do
        it "finds the space" do
          space = create :participatory_space, organization: organization, manifest_name: manifest_name
          expect(subject.space_for(organization)).to eq space
        end
      end
    end
  end
end
