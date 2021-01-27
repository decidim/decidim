# frozen_string_literal: true

module Decidim
  module Core
    autoload :ComponentFinderBase, "decidim/api/functions/component_finder_base"
    autoload :ComponentList, "decidim/api/functions/component_list"
    autoload :ComponentListBase, "decidim/api/functions/component_list_base"
    autoload :NeedsApiFilterAndOrder, "decidim/api/functions/needs_api_filter_and_order"
    autoload :ParticipatorySpaceFinderBase, "decidim/api/functions/participatory_space_finder_base"
    autoload :ParticipatorySpaceListBase, "decidim/api/functions/participatory_space_list_base"
    autoload :UserEntityFinder, "decidim/api/functions/user_entity_finder"
    autoload :UserEntityList, "decidim/api/functions/user_entity_list"

    autoload :AmendmentType, "decidim/api/types/amendment_type"
    autoload :AreaApiType, "decidim/api/types/area_api_type"
    autoload :AreaTypeType, "decidim/api/types/area_type_type"
    autoload :AttachmentType, "decidim/api/types/attachment_type"
    autoload :CategoryType, "decidim/api/types/category_type"
    autoload :ComponentType, "decidim/api/types/component_type"
    autoload :CoordinatesType, "decidim/api/types/coordinates_type"
    autoload :DecidimType, "decidim/api/types/decidim_type"
    autoload :FingerprintType, "decidim/api/types/fingerprint_type"
    autoload :HashtagType, "decidim/api/types/hashtag_type"
    autoload :LocalizedStringType, "decidim/api/types/localized_string_type"
    autoload :MetricHistoryType, "decidim/api/types/metric_history_type"
    autoload :MetricType, "decidim/api/types/metric_type"
    autoload :OrganizationType, "decidim/api/types/organization_type"
    autoload :ParticipatorySpaceType, "decidim/api/types/participatory_space_type"
    autoload :ParticipatorySpaceLinkType, "decidim/api/types/participatory_space_link_type"
    autoload :ScopeApiType, "decidim/api/types/scope_api_type"
    autoload :SessionType, "decidim/api/types/session_type"
    autoload :StatisticType, "decidim/api/types/statistic_type"
    autoload :TraceVersionType, "decidim/api/types/trace_version_type"
    autoload :TranslatedFieldType, "decidim/api/types/translated_field_type"
    autoload :UserGroupType, "decidim/api/types/user_group_type"
    autoload :UserType, "decidim/api/types/user_type"

    autoload :BaseInputFilter, "decidim/api/input_filters/base_input_filter"
    autoload :ComponentInputFilter, "decidim/api/input_filters/component_input_filter"
    autoload :HasHastaggableInputFilter, "decidim/api/input_filters/has_hastaggable_input_filter"
    autoload :HasLocalizedInputFilter, "decidim/api/input_filters/has_localized_input_filter"
    autoload :HasPublishableInputFilter, "decidim/api/input_filters/has_publishable_input_filter"
    autoload :HasTimestampInputFilter, "decidim/api/input_filters/has_timestamp_input_filter"
    autoload :ParticipatorySpaceInputFilter, "decidim/api/input_filters/participatory_space_input_filter"
    autoload :UserEntityInputFilter, "decidim/api/input_filters/user_entity_input_filter"

    autoload :BaseInputSort, "decidim/api/input_sorts/base_input_sort"
    autoload :ComponentInputSort, "decidim/api/input_sorts/component_input_sort"
    autoload :HasEndorsableInputSort, "decidim/api/input_sorts/has_endorsable_input_sort"
    autoload :HasLocalizedInputSort, "decidim/api/input_sorts/has_localized_input_sort"
    autoload :HasPublishableInputSort, "decidim/api/input_sorts/has_publishable_input_sort"
    autoload :HasTimestampInputSort, "decidim/api/input_sorts/has_timestamp_input_sort"
    autoload :ParticipatorySpaceInputSort, "decidim/api/input_sorts/participatory_space_input_sort"
    autoload :UserEntityInputSort, "decidim/api/input_sorts/user_entity_input_sort"

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
