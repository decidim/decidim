# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :comment, class: "Decidim::Comments::Comment" do
    transient do
      skip_injection { false }
    end
    author { build(:user, organization: commentable.organization, skip_injection:) }
    commentable { build(:dummy_resource, :published, skip_injection:) }
    root_commentable { commentable }
    body { Decidim::Faker::Localized.paragraph }
    participatory_space { commentable.try(:participatory_space) }

    after(:build) do |comment, evaluator|
      comment.body = if evaluator.body.is_a?(String)
                       { comment.root_commentable.organization.default_locale || "en" => evaluator.body }
                     else
                       evaluator.body
                     end
      comment.body
    end

    trait :deleted do
      created_at { 1.day.ago }
      deleted_at { 1.hour.ago }
    end

    trait :comment_on_comment do
      author { build(:user, organization: root_commentable.organization, skip_injection:) }
      commentable do
        build(
          :comment,
          author:,
          root_commentable:,
          commentable: root_commentable,
          skip_injection:
        )
      end
      root_commentable { build(:dummy_resource, skip_injection:) }
    end

    trait :moderated do
      after(:create) do |comment, evaluator|
        create(:moderation, reportable: comment, hidden_at: 2.days.ago, skip_injection: evaluator.skip_injection)
      end
    end

    trait :in_favor do
      alignment { 1 }
    end

    trait :against do
      alignment { -1 }
    end
  end

  factory :comment_vote, class: "Decidim::Comments::CommentVote" do
    transient do
      skip_injection { false }
    end
    comment { build(:comment, skip_injection:) }
    author { build(:user, organization: comment.organization, skip_injection:) }
    weight { [-1, 1].sample }

    trait :up_vote do
      weight { 1 }
    end

    trait :down_vote do
      weight { -1 }
    end
  end
end
