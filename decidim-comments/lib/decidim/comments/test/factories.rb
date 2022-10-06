# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :comment, class: "Decidim::Comments::Comment" do
    author { build(:user, organization: commentable.organization) }
    commentable { build(:dummy_resource) }
    root_commentable { commentable }
    body { Decidim::Faker::Localized.paragraph }
    participatory_space { commentable.try(:participatory_space) }

    after(:build) do |comment, evaluator|
      comment.body = if evaluator.body.is_a?(String)
                       { comment.root_commentable.organization.default_locale || "en" => evaluator.body }
                     else
                       evaluator.body
                     end
      comment.body = Decidim::ContentProcessor.parse_with_processor(:hashtag, comment.body, current_organization: comment.root_commentable.organization).rewrite
    end

    trait :deleted do
      created_at { 1.day.ago }
      deleted_at { 1.hour.ago }
    end

    trait :comment_on_comment do
      author { build(:user, organization: root_commentable.organization) }
      commentable do
        build(
          :comment,
          author:,
          root_commentable:,
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
