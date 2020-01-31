# frozen_string_literal: true

module Decidim
  module Core
    class ParticipatorySpaceInputFilter < BaseInputFilter
      include HasPublishableInputFilter

      graphql_name "ParticipatorySpaceFilter"
      description "A type used for filtering any generic participatory space"
    end
  end
end
