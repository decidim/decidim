FactoryBot.define do
  factory :dummy_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_space.organization.available_locales, :surveys).i18n_name }
    manifest_name :dummy
  end
end