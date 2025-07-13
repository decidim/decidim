# frozen_string_literal: true

require "spec_helper"

describe "commented debates badge" do
  let!(:debate) { create(:debate, :ongoing_ama) }
  let(:organization) { debate.component.organization }
  let!(:user) { create(:user, organization:) }

  describe "commenting a debate" do
    let!(:user2) { create(:user, organization:) }
    let!(:other_comment) { create(:comment, author: user2, commentable: debate, root_commentable: debate) }

    context "when creating the first comment" do
      it "increases a user's score" do
        comment = create(:comment, author: user, commentable: debate, root_commentable: debate)
        Decidim::Comments::CommentCreation.publish(comment, {})
        expect(Decidim::Gamification.status_for(user, :commented_debates).score).to eq(1)
      end
    end

    context "when other comments by the same author already exist" do
      it "increases a user's score when a debate is commented" do
        comment = create(:comment, author: user, commentable: debate, root_commentable: debate)
        create(:comment, author: user, commentable: debate, root_commentable: debate)
        Decidim::Comments::CommentCreation.publish(comment, {})

        expect(Decidim::Gamification.status_for(user, :commented_debates).score).to eq(0)
      end
    end
  end

  describe "badge reset" do
    it "resets to the right score" do
      debate2 = create(:debate, :ongoing_ama, component: debate.component)

      create(:comment, author: user, commentable: debate, root_commentable: debate)
      create(:comment, author: user, commentable: debate, root_commentable: debate)
      create(:comment, author: user, commentable: debate2, root_commentable: debate2)

      Decidim::Gamification.reset_badges(Decidim::User.where(id: user.id))
      expect(Decidim::Gamification.status_for(user, :commented_debates).score).to eq(2)
    end
  end
end
