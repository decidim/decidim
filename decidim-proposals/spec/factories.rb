require_relative "../../decidim-core/spec/factories"

FactoryGirl.define do
  factory :proposal, class: Decidim::Proposals::Proposal do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.sentences(3) }
    feature
    author { create(:user, organization: feature.organization) }
  end
end
