require_relative "../../decidim-core/spec/factories"
require_relative "../../decidim-admin/spec/factories"

FactoryGirl.define do
  factory :proposal_feature, class: Decidim::Feature do
    name { { "en" => "Proposals" } }
    manifest_name :proposals
    participatory_process
  end

  factory :proposal, class: Decidim::Proposals::Proposal do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.sentences(3).join("\n") }
    feature
    author { create(:user, organization: feature.organization) }
  end
end
