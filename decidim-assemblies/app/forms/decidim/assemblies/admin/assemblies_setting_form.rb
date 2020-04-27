# frozen_string_literal: true

module Decidim
	module Assemblies
		module Admin
		# A form object used to create assembly setting from the admin dashboard.
			class AssembliesSettingForm < Form
				include TranslatableAttributes
				
				mimic :assemblies_setting

				attribute :organization_chart_enable, Boolean
			end
		end
	end
end
  