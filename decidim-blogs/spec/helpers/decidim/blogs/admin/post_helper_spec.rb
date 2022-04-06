# frozen_string_literal: true

require "spec_helper"

module Decidim::Blogs::Admin
  describe PostsHelper, type: :helper do
    describe "#post_author_select_field" do
      let(:form) { nil }

      context "when option strip_tags is invoked" do
        it "strips the tags from the target string" do
          expect(helper.post_author_select_field(form, name)).eq all_fields
        end
      end
    end
  end
end
