# frozen_string_literal: true

module Decidim
  #
  # Utilities for models that can hold Feature's
  #
  module Featurable
    def demodulized_name
      self.class.name.demodulize
    end

    def foreign_key
      demodulized_name.foreign_key
    end

    def module_name
      "Decidim::#{demodulized_name.pluralize}"
    end

    def underscored_name
      demodulized_name.underscore
    end

    def mounted_engine
      "decidim_#{underscored_name.pluralize}"
    end

    def mounted_admin_engine
      "decidim_admin_#{underscored_name.pluralize}"
    end

    def mounted_params
      { host: organization.host, foreign_key.to_sym => id }
    end

    def extension_module
      "#{module_name}::#{demodulized_name}Context".constantize
    end

    def admin_extension_module
      "#{module_name}::Admin::#{demodulized_name}Context".constantize
    end
  end
end
