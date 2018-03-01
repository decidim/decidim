// = require_self

$("#result_decidim_accountability_status_id").change(function () {
  /* eslint-disable no-invalid-this */
  const progress = $(this).find(':selected').data('progress')
  if (progress || progress === 0) {
    $("#result_progress").val(progress);
  }
});

$(function() {
  $(document).on("open.zf.reveal", "#data_picker-modal", function () {
    $('#data_picker-autocomplete').autoComplete({
      minChars: 2,
      source: function(term, response){
        try { xhr.abort(); } catch(e){}
        $.getJSON('proposals.json', { q: term }, function(data){ console.log(data); response(data); });
      },
      renderItem: function (item, search){
        search = search.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
        var re = new RegExp("(" + search.split(' ').join('|') + ")", "gi");
        var title= item[0]
        var modelId= item[1]
        var val= '#' + modelId + '- ' + title;
        return '<div class="autocomplete-suggestion" data-model-id="' + modelId + '" data-val="'+title+'">' + val.replace(re, "<b>$1</b>") + '</div>';
      },
      onSelect: function(e, term, item){
        let choose= $('#proposal-picker-choose')
        var modelId= item.data('modelId')
        var val= '#' + modelId + '- ' + item.data('val');
        choose.data('picker-value', modelId)
        choose.data('picker-text', val )
        choose.data('picker-choose', '')
      }
    })
  } );
})
