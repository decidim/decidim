require_relative "../../decidim-core/spec/factories"

FactoryGirl.define do
  factory :comment, class: Decidim::Comments::Comment do
    author { build(:user) }
    commentable { build(:participatory_process) }
    body { Faker::Lorem.paragraph }
  end
end