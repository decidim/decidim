Decidim Search MVP
----------

`/search`

```html
<form>
  <input type="text" name="search_term">
  <button type="submit">Search</button>
</form>
```
![screenshot from 2018-01-26 12-50-06](https://user-images.githubusercontent.com/210216/35438610-7bc24a6c-0297-11e8-9829-7d0a537cc3a4.png)
---


`/results`

```html
<header>
  Found <%= result_count %> results for <%= term %>
</header>
<section>
  <article>
    Type:
    Title:
    Url:
  </article>
</section>
```

![screenshot from 2018-01-26 09-59-03](https://user-images.githubusercontent.com/210216/35432597-da12a592-0280-11e8-8997-e83a4762889b.png)
