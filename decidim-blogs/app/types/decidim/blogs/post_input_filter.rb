# frozen_string_literal: true

module Decidim
  module Blogs
    class PostInputFilter < Decidim::Core::BaseInputFilter
      include Decidim::Core::HasTimestampInputFilter

      graphql_name "PostFilter"
      description "A type used for filtering posts inside a participatory space.

A typical query would look like:

```
  {
    participatoryProcesses {
      components {
        ...on Blogs {
          posts(filter:{ createdBefore: \"2020-01-01\" }) {
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
