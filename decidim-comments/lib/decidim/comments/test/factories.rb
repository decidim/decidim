# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :comment, class: "Decidim::Comments::Comment" do
    author { build(:user, organization: commentable.organization) }
    commentable { build(:dummy_resource) }
    root_commentable { commentable }
    body { Faker::Lorem.paragraph }

    trait :comment_on_comment do
      author { build(:user, organization: root_commentable.organization) }
      commentable do
        build(
          :comment,
          author: author,
          root_commentable: root_commentable,
          commentable: root_commentable
        )
      end
      root_commentable { build(:dummy_resource) }
    end
  end

  factory :comment_vote, class: "Decidim::Comments::CommentVote" do
    comment { build(:comment) }
    author { build(:user, organization: comment.organization) }
    weight { [-1, 1].sample }

    trait :up_vote do
      weight { 1 }
    end

    trait :down_vote do
      weight { -1 }
    end
  end
end
