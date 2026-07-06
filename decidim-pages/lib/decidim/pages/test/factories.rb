# frozen_string_literal: true

FactoryBot.define do
  factory :page_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :pages).i18n_name }
    manifest_name { :pages }
    participatory_space { create(:participatory_process, :with_steps, organization:) }

    trait :with_attachments_allowed do
      settings do
        {
          attachments_allowed: true
        }
      end
    end
  end

  factory :page, class: "Decidim::Pages::Page" do
    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    component { build(:component, manifest_name: "pages") }

    transient do
      skip_injection { false }
    end

    trait :with_photo do
      after :create do |page, evaluator|
        page.attachments << create(:attachment, :with_image, attached_to: page, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_document do
      after :create do |page, evaluator|
        page.attachments << create(:attachment, :with_pdf, attached_to: page, skip_injection: evaluator.skip_injection)
      end
    end
  end
end
