require_relative "../../decidim-core/spec/factories"

FactoryGirl.define do
  factory :participatory_process_user_role, class: Decidim::Admin::ParticipatoryProcessUserRole do
    user
    participatory_process
    role "admin"
  end
end
