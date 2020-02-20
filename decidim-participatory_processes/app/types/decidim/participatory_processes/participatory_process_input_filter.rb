# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessInputFilter < Decidim::Core::BaseInputFilter
      include Decidim::Core::HasPublishableInputFilter
      include Decidim::Core::HasHastaggableInputFilter

      graphql_name "ParticipatoryProcessFilter"
      description "A type used for filtering participatory processes"
    end
  end
end
