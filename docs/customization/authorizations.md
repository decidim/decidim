# Authorizations

One particular thing about this kind of applications is the need to Authorize a given user. This is specially important when you want to have legally bindings decisions taken on the platform. There are several ways that this could be done:

* By sending a SMS code to users to verify that their have a valid cellphone

* By allowing users to upload a photo or scanned image of their identity document

* By sending users a code through postal code

* By allowing users to go to to a physical office and check their documentation

* By checking some information through other systems (as a Municipal Census on the case of Municipalities, Cities or Towns)

* By having a list of valid users emails

Right now Decidim supports only a few of these cases, but we have an internal API where you can program your own kind of verifications. You can go see some example code, read more about how to work with Decidim modules, or even see how it’s done for Decidim Barcelona, the Barcelona City Council.
