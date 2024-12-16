# frozen_string_literal: true

require "spec_helper"

module Decidim::Blogs
  describe PostsHelper do
    describe "#render_schema_org_blog_posting_post" do
      subject { helper.render_schema_org_blog_posting_post(post) }

      let!(:post) { create(:post) }

      it "renders a schema.org event" do
        keys = JSON.parse(subject).keys
        expect(keys).to include("@context")
        expect(keys).to include("@type")
        expect(keys).to include("headline")
        expect(keys).to include("author")
        expect(keys).to include("datePublished")
      end
    end
  end
end
