# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :post_component, parent: :component do
    transient do
      skip_injection { false }
    end

    name { generate_component_name(participatory_space.organization.available_locales, :blogs, skip_injection:) }
    manifest_name { :blogs }
    participatory_space { create(:participatory_process, :with_steps, skip_injection:, organization:) }

    trait :with_endorsements_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { endorsements_enabled: true }
        }
      end
    end

    trait :with_endorsements_disabled do
      step_settings do
        {
          participatory_space.active_step.id => { endorsements_enabled: false }
        }
      end
    end

    trait :with_creation_enabled do
      settings do
        {
          creation_enabled_for_participants: true
        }
      end
    end

    trait :with_attachments_allowed_and_creation_enabled do
      settings do
        {
          attachments_allowed: true,
          creation_enabled_for_participants: true
        }
      end
    end
  end

  factory :post, class: "Decidim::Blogs::Post" do
    transient do
      skip_injection { false }
    end

    title { generate_localized_title(:blog_title, skip_injection:) }
    body { generate_localized_description(:blog_body, skip_injection:) }
    component { build(:post_component, skip_injection:) }
    author { build(:user, :confirmed, skip_injection:, organization: component.organization) }
    deleted_at { nil }

    trait :published do
      published_at { 2.minutes.ago }
    end

    trait :with_endorsements do
      after :create do |post, evaluator|
        5.times.collect do
          create(:endorsement,
                 resource: post,
                 skip_injection: evaluator.skip_injection,
                 author: build(:user, :confirmed, skip_injection: evaluator.skip_injection, organization: post.participatory_space.organization))
        end
      end
    end

    trait :hidden do
      after :create do |post, evaluator|
        create(:moderation, hidden_at: Time.current, reportable: post, skip_injection: evaluator.skip_injection)
      end
    end
  end
end
