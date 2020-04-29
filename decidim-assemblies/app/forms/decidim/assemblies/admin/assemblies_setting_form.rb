# frozen_string_literal: true

module Decidim
	module Assemblies
		module Admin
		# A form object used to create assembly setting from the admin dashboard.
			class AssembliesSettingForm < Form
				include TranslatableAttributes
				
				mimic :assemblies_setting

				attribute :enable_organization_chart, Boolean
			end
		end
	end
end
  