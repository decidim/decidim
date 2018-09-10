Decidim::Budgets::Admin::ProjectForm.class_eval do
  attribute :address, String
  attribute :latitude, Float
  attribute :longitude, Float
  validates :address, geocoding: true, if: -> { current_component.settings.geocoding_enabled? }
  alias component current_component
end
