# Authorship

Regarging authorship of Decidim resources/entities, there are three concerns
involved directly:

- `Decidim::ActsAsAuthor`: which defines how an author should behave.
- `Decidim::Authorable` and `Decidim::Coauthorable`: which define the behaviour around who authored a resource.

But the presenters for the classes including `ActsAsAuthor` should also behave
in a certain maneer. This has been resolved using the duck typing strategy
(remember, if it quaks as as duck, then it is a duck). Thus, there's not any
interface declaring which are the methods to be implemented by the presenter
of an author. Anyway one of the `OfficialAuthorPresenter`s may be used as a
reference.