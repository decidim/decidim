# frozen_string_literal: true

require "active_support/concern"

module Decidim
	module TranslatableResource
		extend ActiveSupport::Concern

		included do
			def self.translatable_attributes(list)
				@translatable_attributes = list
			end

			def self.translatable_attributes_list
				@translatable_attributes
			end

		end
	end
end