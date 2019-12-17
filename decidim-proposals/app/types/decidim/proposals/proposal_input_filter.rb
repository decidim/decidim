# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalInputFilter < Decidim::Core::BaseInputFilter
      include Decidim::Core::HasPublishableInputFilter

      graphql_name "ProposalFilter"
      description "A type used for filtering the component proposals.

A typical query would look like:

```
  {
    participatoryProcesses {
      components {
        ...on Proposals {
          proposals(filter:{ publishedBefore: \"2020-01-01\" }) {
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
