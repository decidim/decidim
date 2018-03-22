# Analytics

Decidim, for a matter of privacy, doesn't come bundled (or associated with) any analytics service, leaving that part to the developer.

Adding analytics is quite easy. We've set up a partial in place for that. Just create a view in your app under `app/views/layouts/decidim/_head_extra.html.erb` with your content.

Here's an example for Piwik:

```
<script type="text/javascript">
  var _paq = _paq || [];
  // tracker methods like "setCustomDimension" should be called before "trackPageView"
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u="?????";
    _paq.push(['setTrackerUrl', u+'piwik.php']);
    _paq.push(['setSiteId', '?']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  })();
</script>
```
