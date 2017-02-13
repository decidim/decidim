module Decidim
  class Newsletter < ApplicationRecord
    belongs_to :author
  end
end
