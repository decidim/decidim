# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :post_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :blogs).i18n_name }
    manifest_name { :blogs }
    participatory_space { create(:participatory_process, :with_steps, organization:) }
  end

  factory :post, class: "Decidim::Blogs::Post" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:blog_title, skip_injection:) }
    body { generate_localized_description(:blog_body, skip_injection:) }
    component { build(:component, manifest_name: "blogs") }
    author { build(:user, :confirmed, organization: component.organization) }

    trait :with_endorsements do
      after :create do |post|
        5.times.collect do
          create(:endorsement, resource: post, author: build(:user, organization: post.participatory_space.organization))
        end
      end
    end
  end
end
