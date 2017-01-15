# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe Seed do
      let!(:organization) { create(:organization) }
      let(:subject) { Decidim::Comments::Seed }

      describe "#comments_for(resource)" do
        it 'creates comments for a page if one is given' do
          user = create(:user, organization: organization)
          subject.comments_for(user)
          expect(Decidim::Comments::CommentsWithReplies.for(user).length).to be_between(1, 5).inclusive
        end
      end
    end
  end
end
