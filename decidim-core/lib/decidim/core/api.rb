# frozen_string_literal: true

module Decidim
  module Core
    autoload :ParticipatorySpaceInterface, "decidim/api/participatory_space_interface"
    autoload :ComponentInterface, "decidim/api/component_interface"
    autoload :AuthorInterface, "decidim/api/author_interface"
    autoload :AuthorableInterface, "decidim/api/authorable_interface"
    autoload :CategorizableInterface, "decidim/api/categorizable_interface"
    autoload :ScopableInterface, "decidim/api/scopable_interface"
    autoload :AttachableInterface, "decidim/api/attachable_interface"
    autoload :UserMetricInterface, "decidim/api/user_metric_interface"
    autoload :MetricObjectType, "decidim/api/metric_object_interface"
    autoload :UserMetricObjectInterface, "decidim/api/user_metric_object_interface"
  end
end
