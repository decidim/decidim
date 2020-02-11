# frozen_string_literal: true

module Decidim
  module Core
    autoload :ParticipatorySpaceInterface, "decidim/api/participatory_space_interface"
    autoload :ComponentInterface, "decidim/api/component_interface"
    autoload :AuthorInterface, "decidim/api/author_interface"
    autoload :AuthorableInterface, "decidim/api/authorable_interface"
    autoload :CoauthorableInterface, "decidim/api/coauthorable_interface"
    autoload :CategorizableInterface, "decidim/api/categorizable_interface"
    autoload :ScopableInterface, "decidim/api/scopable_interface"
    autoload :AttachableInterface, "decidim/api/attachable_interface"
    autoload :HashtagInterface, "decidim/api/hashtag_interface"
    autoload :ParticipatorySpaceResourceableInterface, "decidim/api/participatory_space_resourceable_interface"
    autoload :FingerprintInterface, "decidim/api/fingerprint_interface"
    autoload :AmendableInterface, "decidim/api/amendable_interface"
    autoload :AmendableEntityInterface, "decidim/api/amendable_entity_interface"
    autoload :TraceableInterface, "decidim/api/traceable_interface"
    autoload :TimestampsInterface, "decidim/api/timestamps_interface"
  end
end
