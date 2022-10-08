$(() => {
  $("#proposal_answer_template_chooser").change(function(){
      $.getJSON($(this).data('url'), {
        id: $(this).val(),
        proposal_id: $(this).data('proposal')
      }).done(function(data){
        $("#proposal_answer_internal_state_" + data.state).trigger('click');

        let $editors = $("#proposal_answer_template_chooser").parent().parent().find('.tabs-panel').find('.editor-container');
        $editors.each(function(index, element){
          local_element = $(element);
          let $locale = local_element.siblings('input[type=hidden]').attr('id').replace('proposal_answer_answer_', '');
          let editor = Quill.find(element);
          editor.setText(data.template[$locale]);
        });
      });
    });
});
