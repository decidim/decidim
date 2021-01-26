# frozen_string_literal: true

module Decidim
  module Core
    class ParticipatorySpaceInputFilter < BaseInputFilter
      include HasPublishableInputFilter

      graphql_name "ParticipatorySpaceFilter"
      description "A type used for filtering any generic participatory space.

Specific participatory spaces (such as Processes or Assemblies) usually implement their own filter adding capabilities accordingly.

A typical query would look like:

```
  {
    participatoryProcesses(filter:{ publishedBefore: \"2020-01-01\" }) {
      id
    }
  }
```
"
    end
  end
end
