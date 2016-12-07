// = require quill.min
// = require_self

$(document).on('turbolinks:load', () => {
  $(() => {
    const $container = $('.editor-container');
    const quillFormats = ['bold', 'italic', 'link', 'underline', 'header', 'list'];

    $container.each((idx, container) => {
      const toolbar = $(container).data('toolbar');

      let quillToolbar = [
        ['bold', 'italic', 'underline'],
        [{ list: 'ordered' }, { list: 'bullet' }],
        ['link', 'clean']
      ];

      if (toolbar === 'full') {
        quillToolbar = [
          [{ header: [1, 2, 3, 4, 5, 6, false] }],
          ...quillToolbar
        ];
      }

      const $input = $(container).siblings('input[type="hidden"]');
      const quill = new Quill(container, {
        modules: {
          toolbar: quillToolbar
        },
        formats: quillFormats,
        theme: 'snow'
      });

      quill.on('text-change', () => {
        const text = quill.getText();
        if (text === '\n') {
          $input.val('');
        } else {
          $input.val(quill.root.innerHTML);
        }
      });

      quill.root.innerHTML = $input.val();
    });
  });
});
