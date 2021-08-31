# frozen_string_literal: true

module Decidim
  module RectifyQueryExtension
    extend ActiveSupport::Concern

    included do
      alias_method :size, :count
    end
  end
end
