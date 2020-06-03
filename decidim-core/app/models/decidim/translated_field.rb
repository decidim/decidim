module Decidim
  class TranslatedField < ApplicationRecord

    belongs_to :resource,
               polymorphic: true,
  end
end
