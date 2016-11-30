# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe Comment do
      let(:comment) { build(:comment) }

      it "is valid" do
        expect(comment).to be_valid
      end

      it "has an associated author" do
        expect(comment.author).to be_a(Decidim::User)
      end
    end
  end
end
