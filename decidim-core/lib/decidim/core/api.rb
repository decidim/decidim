# frozen_string_literal: true

module Decidim
  module Core
    autoload :CategoryType, "decidim/api/types/category_type"
    autoload :MetricHistoryType, "decidim/api/types/metric_history_type"
    autoload :TranslatedFieldType, "decidim/api/types/translated_field_type"
    autoload :ScopeApiType, "decidim/api/types/scope_api_type"
    autoload :UserType, "decidim/api/types/user_type"

    autoload :ParticipatorySpaceInterface, "decidim/api/interfaces/participatory_space_interface"
    autoload :ComponentInterface, "decidim/api/interfaces/component_interface"
    autoload :AuthorInterface, "decidim/api/interfaces/author_interface"
    autoload :AuthorableInterface, "decidim/api/interfaces/authorable_interface"
    autoload :CoauthorableInterface, "decidim/api/interfaces/coauthorable_interface"
    autoload :CategorizableInterface, "decidim/api/interfaces/categorizable_interface"
    autoload :ScopableInterface, "decidim/api/interfaces/scopable_interface"
    autoload :AttachableInterface, "decidim/api/interfaces/attachable_interface"
    autoload :HashtagInterface, "decidim/api/interfaces/hashtag_interface"
    autoload :ParticipatorySpaceResourceableInterface, "decidim/api/interfaces/participatory_space_resourceable_interface"
    autoload :FingerprintInterface, "decidim/api/interfaces/fingerprint_interface"
    autoload :AmendableInterface, "decidim/api/interfaces/amendable_interface"
    autoload :AmendableEntityInterface, "decidim/api/interfaces/amendable_entity_interface"
    autoload :TraceableInterface, "decidim/api/interfaces/traceable_interface"
    autoload :TimestampsInterface, "decidim/api/interfaces/timestamps_interface"
    autoload :EndorsableInterface, "decidim/api/interfaces/endorsable_interface"

    autoload :DateTimeType, "decidim/api/scalars/date_time_type"
    autoload :DateType, "decidim/api/scalars/date_type"
  end
end
