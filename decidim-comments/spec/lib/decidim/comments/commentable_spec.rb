# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::Commentable do
  subject { dummy_resource }

  let(:dummy_resource) { create :dummy_resource }
  let!(:top_level_comment) { create :comment, commentable: dummy_resource }
  let!(:second_level_comment) { create :comment, commentable: top_level_comment, root_commentable: dummy_resource }

  describe "comment_threads" do
    it "only returns top-level comments" do
      expect(subject.comment_threads).to eq [top_level_comment]
    end
  end

  describe "comments" do
    it "returns comments in all levels" do
      expect(subject.comments).to match_array [top_level_comment, second_level_comment]
    end
  end
end
