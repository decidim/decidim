# frozen_string_literal: true

module Decidim
  module Attributes
    autoload :TimeWithZone, "decidim/attributes/time_with_zone"
    autoload :LocalizedDate, "decidim/attributes/localized_date"
    autoload :CleanString, "decidim/attributes/clean_string"

    ActiveModel::Type.register(:"decidim/attributes/time_with_zone", Decidim::Attributes::TimeWithZone)
    ActiveModel::Type.register(:"decidim/attributes/localized_date", Decidim::Attributes::LocalizedDate)
    ActiveModel::Type.register(:"decidim/attributes/clean_string", Decidim::Attributes::CleanString)
    ActiveModel::Type.register(:date_time, ActiveModel::Type::DateTime) # Synonym for :datetime
  end
end
