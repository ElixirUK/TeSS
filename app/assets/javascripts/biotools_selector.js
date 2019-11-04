var lookupDelay = 100;
var lookupTimeout = null;
var lookupCache = {};

class BioToolsSelector {

    static newToolText(){
        return  "<div class=''>" +
                    "<i class='glyphicon glyphicon-plus'></i> Custom tool" +
                "</div>"
    }

    constructor(id, preset_id, preset_value){
        var config = {
            placeholder: true,
            placeholderValue: 'Search Biotools API',
            maxItemCount: 20,
            searchChoices: false,
            duplicateItemsAllowed: false,
            removeItemButton: true,
            shouldSort: false,
            addItems: true,
            addItemText: (value) => {
                return `Press Enter to add <b>"${value}"</b>`;
            },
            noChoicesText: 'Start typing to query bio.tools',
            itemSelectText: '',
            searchFields: ['label', 'value']
        };
        if (preset_id && preset_value){
            config['choices'] = [{
                value: preset_id,
                label: preset_value,
                selected: true
            }]
        }
        //config['choices'].push({
        //    value: BioToolsSelector.newToolText()
        //})
        this.element = $(id)[0];
        this.selector = new Choices(this.element, config);

        let self = this;

        //When user types into the search area: query biotools or load from cache, and display results.
        this.element.addEventListener('search', function(){
            clearTimeout(lookupTimeout);
            lookupTimeout = setTimeout(()=>{self.query({'q': self.selector.input.value})}, lookupDelay);
        });
    }



    static populateChoices(selector, returned_choices){
         var choices = [];
         returned_choices.list.forEach(function(element){
           choices.push({
                 value: element.biotoolsID,
                 label: element.name
           })
         });
         choices.push({
             value: BioToolsSelector.newToolText()
         })
         selector.setChoices(choices, 'value', 'label', true);
    }

    /* params:
          q: query_param
          operation: operation_param
    */
    query(query){

        const base_url = 'https://bio.tools/api/tool/?format=json&sort=score';
        const selector = this.selector;
        let query_url = false;

        if (query['q']){
            query_url = base_url + '&q=' + query['q'];
        } else if (query['operation']) {
            query_url = base_url + '&operation=' + query['operation'];
        }
        if (query_url){
            if (query_url in lookupCache) {
                BioToolsSelector.populateChoices(selector, lookupCache[query_url]);
            } else {
                fetch(query_url)
                    .then(function(response) {
                        response.json().then(function(data) {
                            lookupCache[query_url] = data;
                            BioToolsSelector.populateChoices(selector, data);
                        });
                    })
                    .catch(function(error) {
                        console.error(error);
                    });
            }
        }
    }
}
