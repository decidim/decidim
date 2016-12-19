# frozen_string_literal: true
FactoryGirl.define do
  factory :comment, class: Decidim::Comments::Comment do
    author { build(:user, organization: commentable.organization) }
    commentable { build(:participatory_process) }
    body { Faker::Lorem.paragraph }
  end

  factory :comment_vote, class: Decidim::Comments::CommentVote do
    author { build(:user) }
    comment { build(:comment) }
    weight { [-1, 1].sample }

    trait :up_vote do
      weight 1
    end

    trait :down_vote do
      weight(-1)
    end
  end
end
