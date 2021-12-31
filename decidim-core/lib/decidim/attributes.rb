# frozen_string_literal: true

module Decidim
  module Attributes
    autoload :TimeWithZone, "decidim/attributes/time_with_zone"
    autoload :LocalizedDate, "decidim/attributes/localized_date"
    autoload :CleanString, "decidim/attributes/clean_string"
    autoload :Symbol, "decidim/attributes/symbol"
    autoload :Integer, "decidim/attributes/integer"

    ActiveModel::Type.register(:"decidim/attributes/time_with_zone", Decidim::Attributes::TimeWithZone)
    ActiveModel::Type.register(:"decidim/attributes/localized_date", Decidim::Attributes::LocalizedDate)
    ActiveModel::Type.register(:"decidim/attributes/clean_string", Decidim::Attributes::CleanString)
    ActiveModel::Type.register(:symbol, Decidim::Attributes::Symbol)
    ActiveModel::Type.register(:date_time, ActiveModel::Type::DateTime) # Synonym for :datetime

    # Overrides
    # The overrides deletion can be omitted after upgrade to Rails 7.0 (delete this)
    ActiveModel::Type.registry.send(:registrations).delete_if { |r| r.send(:name) == :integer }

    ActiveModel::Type.register(:integer, Decidim::Attributes::Integer)
  end
end
