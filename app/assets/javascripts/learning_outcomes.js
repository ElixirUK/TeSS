var type='learning-outcomes';//or 'prerequisites'

var LearningOutcomes = {
    add: function (noun, verb) {
        var newForm = $('#' + type + '-template').clone().html();

        // Ensure the index of the new form is 1 greater than the current highest index, to prevent collisions
        var index = 0;
        $('#' + type + '-list .' + type + '-form').each(function () {
            var newIndex = parseInt($(this).data('index'));
            if (newIndex > index) {
                index = newIndex;
            }
        });

        // Replace the placeholder index with the actual index
        newForm = $(newForm.replace(/replace-me/g, index + 1));
        newForm.appendTo('#' + type + '-list');

        if (typeof title !== 'undefined' && typeof url !== 'undefined') {
            $('.' + type + '-noun', newForm).val(noun);
            $('.' + type + '-verb', newForm).val(verb);
        }

        return false; // Stop form being submitted
    },

    // This is just cosmetic. The actual removal is done by rails,
    //   by virtue of the hidden checkbox being checked when the label is clicked.
    delete: function () {
        $(this).parents('.' + type + '-form').fadeOut();
    }
};

document.addEventListener("turbolinks:load", function() {
    $('#learning-outcomes')
        .on('click', '#add-learning-outcomes-btn', LearningOutcomes.add)
        .on('change', '.delete-learning-outcomes-btn input.destroy-attribute', LearningOutcomes.delete);
});
