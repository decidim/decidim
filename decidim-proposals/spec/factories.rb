require "decidim/core/test/factories"
require "decidim/admin/test/factories"
require "decidim/comments/test/factories"

FactoryGirl.define do
  factory :proposal_feature, class: Decidim::Feature do
    name { Decidim::Features::Namer.new(participatory_process.organization.available_locales, :proposals).i18n_name }
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
