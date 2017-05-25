# frozen_string_literal: true

module Decidim
  autoload :AuthorInterface, "decidim/core/api/author_interface"
  autoload :TranslatedFieldType, "decidim/core/api/translated_field_type"
  autoload :LocalizedStringType, "decidim/core/api/localized_string_type"
  autoload :ProcessStepType, "decidim/core/api/process_step_type"
  autoload :ProcessType, "decidim/core/api/process_type"
  autoload :SessionType, "decidim/core/api/session_type"
  autoload :UserGroupType, "decidim/core/api/user_group_type"
  autoload :UserType, "decidim/core/api/user_type"
  autoload :DecidimType, "decidim/core/api/decidim_type"
end
