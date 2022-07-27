# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe Export do
      subject { described_class }
      let!(:component) { create(:component, manifest_name: "dummy") }
      let!(:dummy_resources) { create_list(:dummy_resource, 2, component:) }
      let!(:comments) { create_list(:comment, 5, commentable: dummy_resources[1], root_commentable: dummy_resources[1]) }
      let!(:other_comments) { create_list(:comment, 5) }

      describe "#comments_for_resource" do
        let(:collection) { subject.comments_for_resource(Decidim::DummyResources::DummyResource, component) }

        it "returns a collection of comments" do
          expect(collection).to include(*comments)
        end

        it "excludes other comments" do
          expect(collection).not_to include(*other_comments)
        end
      end
    end
  end
end
