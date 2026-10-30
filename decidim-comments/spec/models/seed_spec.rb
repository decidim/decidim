# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe Seed do
      subject { described_class }

      describe "#comments_for(resource)" do
        it "creates comments for a page if one is given" do
          dummy_resource = create(:dummy_resource)
          subject.comments_for(dummy_resource)
          expect(Decidim::Comments::SortedComments.for(dummy_resource).length).to be_between(0, 6).inclusive
        end

        it "stores the participatory space for the seeded comments" do
          dummy_resource = create(:dummy_resource)
          allow(subject).to receive(:config_value).with(:comments_per_resource_count).and_return(1)
          allow(subject).to receive(:config_value).with(:comments_nested_probability).and_return(0)
          allow(subject).to receive(:config_value).with(:comments_vote_skip_probability).and_return(1)

          subject.comments_for(dummy_resource)

          comment = Decidim::Comments::Comment.last
          expect(comment.participatory_space).to eq(dummy_resource.participatory_space)
        end
      end
    end
  end
end
