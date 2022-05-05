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
          expect(Decidim::Comments::SortedComments.for(dummy_resource).length).to be_between(1, 5).inclusive
        end
      end
    end
  end
end
