EDAM_BRANCH = 'operation';
BIOTOOLS_SELECTORS = {};

function get_current_index(statement_type){
    // Find the element with the highest data-index for this type
    // Return -1 if non-exist
    let index = -1;
    $('#' + statement_type + '-list .' + statement_type + '-form').each(function () {
        let newIndex = parseInt($(this).data('index'));
        if (newIndex > index) {
            index = newIndex;
        }
    });
    return index
}

var LearningStatement = {
    // type = 'learning-outcomes' or 'prerequisites'
    add: function (statement_type){

        var newForm = $('#' + statement_type + '-template').clone().html();
        var index = get_current_index(statement_type, this);
        // Replace the placeholder index with the actual index
        index = index + 1;
        newForm = $(newForm.replace(/replace-me/g, index));
        newForm.appendTo('#' + statement_type + '-list');

        initialize_dictionary_selector(statement_type, 'verb', index);
        //initialize_edam_selector(statement_type, index);
        initialize_dictionary_selector(statement_type, 'noun', index);
        initialize_tool_selector(statement_type, index);

        return false; // Stop form being submitted
    },


    // This is just cosmetic. The actual removal is done by rails,
    //   by virtue of the hidden checkbox being checked when the label is clicked.
    delete: function (delete_button, statement_type) {
        $(delete_button).parents('.' + statement_type + '-form').fadeOut();
    }
};

let LearningOutcomes = {
    add: function () {
        LearningStatement.add('learning-outcomes');return false;
    },
    delete: function() {
        LearningStatement.delete(this, 'learning-outcomes'); return false;
    }
};

let Prerequisites = {
    add: function () {
        LearningStatement.add('prerequisites'); return false;
    },
    delete: function() {
        LearningStatement.delete(this, 'prerequisites'); return false;
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
    Returns the HTML element ID string for a prerequisite or learning outcome _index_
    Uses a data attribute called form-name to find out what type of resource we are on
     (e.g material or event)
 */
function construct_html_element_id(statement_type, statement_participle, index, hidden=false){
    let statement_type_bounding_box = $('#learning-statements')[0];
    let resource_type = $(statement_type_bounding_box).data('form-name'); // material or event
    if (hidden){
        return "#" + resource_type + "_" + statement_type.split('-').join("_") + "_attributes_" + index + '_' + statement_participle;
    } else {
        return "#" + resource_type + "_" + statement_type.split('-').join("_") + "_attributes_" + statement_participle + "_" + index;
    }
}

function initialize_dictionary_selector(statement_type, dictionary_type, index){
    let hidden_existing_value = construct_html_element_id(statement_type, dictionary_type, index, hidden=true);
    let html_element_id = construct_html_element_id(statement_type, dictionary_type, index);

    let selected_term = $(hidden_existing_value).val();

    var config = {
        placeholder: true,
        placeholderValue: 'Find a ' + dictionary_type,
        maxItemCount: 20,
        searchResultLimit: 20,
        searchChoices: true,
        duplicateItemsAllowed: false,
        removeItemButton: true,
        shouldSort: true,
        noResultsText: 'Could not find the ' + dictionary_type + ' you are looking for. Please try a different term',
        itemSelectText: ''
    };
    var elem = $(html_element_id)[0];
    var choices = new Choices(elem, config);

    if (selected_term && selected_term.length > 0){
        choices.setChoices([{
            value: selected_term,
            label: selected_term,
            selected: true,
            replaceChoices: true
        }])
    }
    //Copy selection to hidden field ready for submission
    //This hidden field ID is in the necessary format dictated by accepts_nested_attributes_for
    elem.addEventListener('change', function(event){
        $('#' + event.target.dataset.hiddenId).val(event.detail.value);
    });
}


function initialize_edam_selector(statement_type, index){
    let hidden_existing_value = construct_html_element_id(statement_type, 'noun', index, hidden=true);
    let html_element_id = construct_html_element_id(statement_type, 'noun', index, hidden=false);
    let value = $(hidden_existing_value).val();

    if (value){
        edamSelector(html_element_id, [value]);
    } else {
        edamSelector(html_element_id)
    }
}



// Uses Choices.js https://github.com/jshjohnson/Choices/tree/v7.0.0
// Baked in at; https://github.com/jshjohnson/Choices/tree/5cf226f16643838b9a4232f2fc42c134e6096025
// Guide to using Choices.js for remote lookup service: https://github.com/jshjohnson/Choices/issues/162
function initialize_tool_selector(statement_type, index){

    let html_element_id = construct_html_element_id(statement_type, 'tool', index);
    let hidden_existing_value = construct_html_element_id(statement_type, 'tool', index, hidden=true);

    let selected_id = $(hidden_existing_value + '_id').val();
    let selected_name = $(hidden_existing_value + '_name').val();

    const tool_selector = new BioToolsSelector(html_element_id, selected_id, selected_name);

    tool_selector.query(tool_selector.selector.input.value);

    //Copy selection to hidden field ready for submission
    //This hidden field ID is in the necessary format dictated by accepts_nested_attributes_for
    tool_selector.element.addEventListener('change', function(event){
        $('#' + event.target.dataset.hiddenId + '_id').val(event.detail.value);
        $('#' + event.target.dataset.hiddenId + '_name').val(event.target.textContent);
    });

    BIOTOOLS_SELECTORS[html_element_id] = tool_selector
}



/*
    Load a verb, edam selector and biotool selector; for each
    of the _i_ prereqs/learning outcomes.

    statement_type is either learning-outcomes or prerequisites
 */
function initialize_selectors(statement_type) {
    //counts how many instances of this type of learning statement there are
    let index = get_current_index(statement_type);
    if (index >= 0){
        //initiate an edam and tool selectors for this learning statement
        for (let i = 0; i <= index; i++) {
            // note: tool selector must be initialized first in order for the edam selector
            //       edam:change event to query the tool selector with the selected operation
            initialize_tool_selector(statement_type, i);
            //initialize_edam_selector(statement_type, i);
            initialize_dictionary_selector(statement_type, 'verb', i);
            initialize_dictionary_selector(statement_type, 'noun', i);

        }
    }
}


document.addEventListener('edam:change', (event) => {
    /*
        Add listeners to set hidden field with selected EDAM term
        The ID for the hidden field is index then participle type.
        The ID for the select element is participle type then index.
        e.g hidden field id: "#event_learning_outcomes_attributes_0_noun"
            select field id: "#event_learning_outcomes_attributes_noun_0"
     */

    let event_data = event.detail;
    let existing_id = event_data.name; //e.g "#event_learning_outcomes_attributes_noun_0"
    let temp = existing_id.split("_");
    let index = temp.pop();
    let participle_type = temp.pop();
    let base = temp.join('_');
    let hidden_id = base + "_" + index + "_" + participle_type;
    $(hidden_id).val('http://edamontology.org/' + EDAM_BRANCH + "_" + event_data.selected[0][1]);

    //Update biotools selector items with tools matching selected operation

    let tool_selector_id = [base, 'tool', index].join('_');
    let tool_selector = BIOTOOLS_SELECTORS[tool_selector_id];
    tool_selector.query({'operation': event_data.selected[0][2]});

});

document.addEventListener("turbolinks:load", function() {

    $('#learning-outcomes')
        .on('click', '#add-learning-outcomes-btn', LearningOutcomes.add)
        .on('change', '.delete-learning-statement-btn input.destroy-attribute', LearningOutcomes.delete);
    initialize_selectors('learning-outcomes')
    $('#prerequisites')
        .on('click', '#add-prerequisites-btn', Prerequisites.add)
        .on('change', '.delete-learning-statement-btn input.destroy-attribute', Prerequisites.delete);
    initialize_selectors('prerequisites')
});
