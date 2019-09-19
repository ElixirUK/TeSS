EDAM_BRANCH = 'operation';


function get_current_index(type){
    // Ensure the index of the new form is 1 greater than the current highest index, to prevent collisions
    let index = 0;
    $('#' + type + '-list .' + type + '-form').each(function () {
        let newIndex = parseInt($(this).data('index'));
        if (newIndex > index) {
            index = newIndex;
        }
    });
    return index
}

let LearningStatement = {
    // type = 'learning-outcomes' or 'prerequisites'
    add: function (type){
        let newForm = $('#' + type + '-template').clone().html();
        let index = get_current_index(type, this);
        // Replace the placeholder index with the actual index
        index = index + 1;
        newForm = $(newForm.replace(/replace-me/g, index));
        newForm.appendTo('#' + type + '-list');

        let html_element_id = construct_html_element_id(type, index);
        edamSelector(html_element_id);

        return false; // Stop form being submitted
    },

    // This is just cosmetic. The actual removal is done by rails,
    //   by virtue of the hidden checkbox being checked when the label is clicked.
    delete: function (delete_button, type) {
        $(delete_button).parents('.' + type + '-form').fadeOut();
    }
};


let LearningOutcomes = {
    add: function () {
        LearningStatement.add('learning-outcomes');
        return false;
    },
    delete: function() {
        LearningStatement.delete(this, 'learning-outcomes');
    }
};


let Prerequisites = {
    add: function () {
        LearningStatement.add('prerequisites');
        return false;
    },
    delete: function() {
        LearningStatement.delete(this, 'prerequisites');
        return false;
    }
};

// Courtesy of Ivan Kuzmin
//   https://inkuzmin.github.io/edam-select/

function edamSelector(html_element_id, preset_values=false){
    let edamSelect = new EdamSelect(html_element_id, {
        name: html_element_id,          // optional
        type: EDAM_BRANCH,
        initDepth: 1,           // default
        inline: false,          // default
        closeOnSelect: true,    // conditional default
        maxHeight: 300,         // optional
        multiselect: false,     // default
        checkboxes: false,      // default
        search: {               // default
            threshold: 0.1,
            label: true,
            synonyms: false,
            definitions: false,
        },
        preselected: preset_values     // default
    });

}


/*
    Returns the HTML element ID string for a prerequisite or learning outcome _i_
    Depends on #learning-statments having a data attribute to give the resource type (e.g material or event)
 */
function construct_html_element_id(type, index){
    let statement_type_bounding_box = $('#learning-statements')[0];
    let resource_type = $(statement_type_bounding_box).data('form-name'); // material or event
    return "#" + resource_type + "_" + type.split('-').join("_") + "_attributes_" + index;
}

function initialize_edam_selectors(type) {
    //counts how many instances of this type of learning statement there are
    let index = get_current_index(type);
    if (index > 0){
        //initiate edam selectors for each learning statement type
        for (let i = 0; i <= index; i++) {
            let html_element_id = construct_html_element_id(type, i);

            let value = $(html_element_id + "_noun").val();
            if (value){
                edamSelector(html_element_id, [value])
            } else {
                edamSelector(html_element_id)
            }
        }
    }
}

document.addEventListener("turbolinks:load", function() {
    initialize_edam_selectors('learning-outcomes');
    $('#learning-outcomes')
        .on('click', '#add-learning-outcomes-btn', LearningOutcomes.add)
        .on('change', '.delete-learning-outcomes-btn input.destroy-attribute', LearningOutcomes.delete);

});

document.addEventListener("turbolinks:load", function() {
    $('#prerequisites')
        .on('click', '#add-prerequisites-btn', Prerequisites.add)
        .on('change', '.delete-prerequisites-btn input.destroy-attribute', Prerequisites.delete);
    initialize_edam_selectors('prerequisites');
});

document.addEventListener('edam:change', (event) => {
    let event_data = event.detail;
    $(event_data.name + "_noun").val('http://edamontology.org/' + EDAM_BRANCH + "_" + event_data.selected[0][1]);
});
// Add listeners to set form field item with selected data