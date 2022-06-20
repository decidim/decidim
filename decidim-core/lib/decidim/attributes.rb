# frozen_string_literal: true

module Decidim
  module Attributes
    autoload :TimeWithZone, "decidim/attributes/time_with_zone"
    autoload :LocalizedDate, "decidim/attributes/localized_date"
    autoload :CleanString, "decidim/attributes/clean_string"
    autoload :Blob, "decidim/attributes/blob"
    autoload :Array, "decidim/attributes/array"
    autoload :Hash, "decidim/attributes/hash"
    autoload :Object, "decidim/attributes/object"
    autoload :Model, "decidim/attributes/model"
    autoload :Symbol, "decidim/attributes/symbol"
    autoload :Integer, "decidim/attributes/integer"

    # Base types
    ActiveModel::Type.register(:array, Decidim::Attributes::Array)
    ActiveModel::Type.register(:hash, Decidim::Attributes::Hash)
    ActiveModel::Type.register(:object, Decidim::Attributes::Object)
    ActiveModel::Type.register(:model, Decidim::Attributes::Model)
    ActiveModel::Type.register(:symbol, Decidim::Attributes::Symbol)

    # Synonyms
    ActiveModel::Type.register(:date_time, ActiveModel::Type::DateTime) # Synonym for :datetime

    # Extra types
    ActiveModel::Type.register(:"decidim/attributes/time_with_zone", Decidim::Attributes::TimeWithZone)
    ActiveModel::Type.register(:"decidim/attributes/localized_date", Decidim::Attributes::LocalizedDate)
    ActiveModel::Type.register(:"decidim/attributes/clean_string", Decidim::Attributes::CleanString)
    ActiveModel::Type.register(:"decidim/attributes/blob", Decidim::Attributes::Blob)

    # Overrides
    # The overrides deletion can be omitted after upgrade to Rails 7.0 (delete this after upgrade)
    ActiveModel::Type.registry.send(:registrations).delete_if { |r| r.send(:name) == :integer }

    ActiveModel::Type.register(:integer, Decidim::Attributes::Integer)
  end
end
