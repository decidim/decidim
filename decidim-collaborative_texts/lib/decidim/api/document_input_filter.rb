# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class DocumentInputFilter < Decidim::Core::BaseInputFilter
      include Decidim::Core::HasTimestampInputFilter

      graphql_name "CollaborativeTextFilter"
      description "A type used for filtering collaborative texts inside a participatory space.

A typical query would look like:

```
  {
    participatoryProcesses {
      components {
        ...on CollaborativeTexts {
          collaborativeTexts(filter:{ createdBefore: \"2020-01-01\" }) {
            id
          }
        }
      }
    }
  }
```
"
    end
  end
end
