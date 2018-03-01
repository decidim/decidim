# Authorizations

One particular thing about this kind of applications is the need to Authorize a given user. This is specially important when you want to have legally bindings decisions taken on the platform. There are several ways that this could be done:

* By sending a SMS code to users to verify that their have a valid cellphone

* By allowing users to upload a photo or scanned image of their identity document

* By sending users a code through postal code

* By allowing users to go to to a physical office and check their documentation

* By checking some information through other systems (as a Municipal Census on the case of Municipalities, Cities or Towns)

* By having a list of valid users emails

Right now Decidim supports only a few of these cases, but we have an internal API where you can program your own kind of authorizations. To create your own `AuthorizationHandler` for an external API (ie a Municipal Census) you should add a `app/services/` file, then activate it on `config/initializers/decidim.rb` and finally enabling it on `/system` for the tenant.

You can go see some example code on:

* [Erabaki Pamplona](https://github.com/ErabakiPamplona/erabaki/blob/master/app/services/census_authorization_handler.rb)

* [Decidim Barcelona](https://github.com/AjuntamentdeBarcelona/decidim-barcelona/blob/master/app/services/census_authorization_handler.rb)

* [Decidim Terrassa](https://github.com/AjuntamentDeTerrassa/decidim-terrassa/blob/master/app/services/census_authorization_handler.rb)

* [Decidim Sant Cugat](https://github.com/AjuntamentdeSantCugat/decidim-sant_cugat/blob/master/app/services/census_authorization_handler.rb)

These are just a few examples but mostly all the Municipal installations have somekind of Authorization.
