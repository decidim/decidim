# frozen_string_literal: true

FactoryGirl.define do
  factory :participatory_process_user_role, class: Decidim::ParticipatoryProcessUserRole do
    user
    participatory_process
    role "admin"
  end
end
