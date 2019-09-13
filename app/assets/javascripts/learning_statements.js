
function get_current_index(type){
    // Ensure the index of the new form is 1 greater than the current highest index, to prevent collisions
    var index = 0;
    $('#' + type + '-list .' + type + '-form').each(function () {
        var newIndex = parseInt($(this).data('index'));
        if (newIndex > index) {
            index = newIndex;
        }
    });
    return index
}

var LearningStatement = {
    add: function (noun, verb, type){
        var newForm = $('#' + type + '-template').clone().html();

        var index = get_current_index(type, this)

        // Replace the placeholder index with the actual index
        newForm = $(newForm.replace(/replace-me/g, index + 1));
        newForm.appendTo('#' + type + '-list');

        if (typeof title !== 'undefined' && typeof url !== 'undefined') {
            $('.' + type + '-noun', newForm).val(noun);
            $('.' + type + '-verb', newForm).val(verb);
        }
        edamSelector(index+1)
        return false; // Stop form being submitted
    },

    // This is just cosmetic. The actual removal is done by rails,
    //   by virtue of the hidden checkbox being checked when the label is clicked.
    delete: function () {
        $(this).parents('.' + type + '-form').fadeOut();
    }
};


var LearningOutcomes = {
    add: function (noun, verb) {
        LearningStatement.add(noun, verb, 'learning-outcomes');
        return false;
    },
    delete: function() {
        LearningStatement.delete('learning-outcomes');
    }
};


var Prerequisites = {
    add: function (noun, verb) {
        LearningStatement.add(noun, verb, 'prerequisites');
        return false;
    },
    delete: function() {
        LearningStatement.delete('prerequisites');
    }
};

function edamSelector(index){
    var html_element_id = "#edam-select-" + index
    let edamSelect = new EdamSelect(html_element_id, {
        name: 'ref-1',          // optional
        type: 'operation',
        initDepth: 2,           // default
        inline: false,          // default
        closeOnSelect: true,    // conditional default
        maxHeight: 300,         // optional
        multiselect: false,     // default
        checkboxes: false,      // default
        search: {               // default
            threshold: 0.1,
            label: false,
            synonyms: false,
            definitions: false,
        },
        preselected: false      // default
    });
}

function initialize_edam_selectors(type){
    console.log(get_current_index(type))
}

document.addEventListener("turbolinks:load", function() {
    initialize_edam_selectors("LearningOutcome")
    edamSelector(0)
    edamSelector(1)
    $('#learning-outcomes')
        .on('click', '#add-learning-outcomes-btn', LearningOutcomes.add)
        .on('change', '.delete-learning-outcomes-btn input.destroy-attribute', LearningOutcomes.delete);
});

document.addEventListener("turbolinks:load", function() {
    $('#prerequisites')
        .on('click', '#add-prerequisites-btn', Prerequisites.add)
        .on('change', '.delete-prerequisites-btn input.destroy-attribute', Prerequisites.delete);
});
