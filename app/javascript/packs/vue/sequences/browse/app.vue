<template>
    <div id="browse_sequences">
        <div class="filters-container">
            <div id="gene_name" class="filter-container">
                <h3>Gene name</h3>
                <autocomplete
                    id="gene_autocomplete"
                    url="/descriptors/autocomplete" 
                    param="term" 
                    min="1" 
                    label="label"
                    placeholder="Enter Gene name"
                    @getItem="loadGene"
                    @getInput="getGeneInput"
                    :class="{ 'valid-input': currentParams.gene_descriptor_id }">
                </autocomplete>
                <span></span>
            </div>
            <div id="otu" class="filter-container">
                <h3>Otu</h3>
                <div>
                    <autocomplete
                        id="otu_autocomplete"
                        url="/otus/autocomplete"
                        param="term"
                        min="3"
                        label="label"
                        placeholder="Enter Otu name"
                        @getItem="loadOtu"
                        @getInput="getOtuInput"
                        :class="{ 'valid-input': currentParams.otu_id }">
                    </autocomplete>
                    <span></span>
                </div>
                <div id="otu_descendants_container">
                    <label>
                        Descendants
                        <input type="checkbox" id="otu_descendants_checkbox" v-model="currentParams.otu_descendants">
                    </label>
                </div>
            </div>
            <div id="collection_object_namespace" class="filter-container">
                <h3>Collection object identifier</h3>
                <div>
                    <autocomplete
                        id="namespace_autocomplete"
                        url="/namespaces/autocomplete"
                        param="term"
                        min="1"
                        label="label"
                        placeholder="Enter namespace"
                        @getItem="loadCollectionObjectNamespace"
                        @getInput="getCollectionObjectNamespaceInput"
                        :class="{ 'valid-input': currentParams.collection_object_namespace_id }">
                    </autocomplete>
                    <span></span>
                </div>
                <div>
                    <input
                    type="text"
                    v-model="currentParams.collection_object_identifier"
                    :class="{ 'valid-input': currentParams.collection_object_identifier }"
                    placeholder="Enter identifier">
                    <span></span>
                </div>
            </div>
            <div id="search_button">
                <input id="find_button" type="submit" @click="findSequences" class="button-request">
            </div>
        </div>
        <paged-table
            ref="pagedTable"
            title="Displaying sequences"
            :list="list"
            :header="header"
            :attributes="attributes"
            :edit="true"
            :destroy="false"
            @edit="editSequence"
            @pageSelected="pageSelected">
        </paged-table>
    </div>
</template>

<script>
    import autocomplete from "../../components/autocomplete.vue";
    import pagedTable from "./components/pagedTable.vue";

    export default {
        components: {
            autocomplete,
            pagedTable
        },
        data: function() {
            return {
                params: {
                    otu_id: null,
                    otu_descendants: null,
                    collection_object_namespace_id: null,
                    collection_object_identifier: null,
                    gene_descriptor_id: null,
                    page: 1
                },
                currentParams: {},
                list: [],
                header: [
                    "Name"
                ],
                attributes: [
                    "name"
                ]
            }
        },
        mounted: function() {
            this.currentParams = Object.assign({}, this.params);
            
            this.$nextTick(function() {
                let foundParam = false;
                let url = new URL(window.location.href);

                for(let key in this.params) {
                    if(url.searchParams.has(key)) {
                        let val = url.searchParams.get(key);

                        if(key === "page") {
                            val = parseInt(val, 10);
                            val = val <= 0 ? 1 : val;
                        }

                        foundParam = true;
                        this.params[key] = val;
                        this.currentParams[key] = val;
                    } 
                }

                if(foundParam)
                    this.loadSequences();
            });

            window.onpopstate = (event) => {
                if(event.state.params) {
                    this.params = Object.assign({}, this.params, event.state.params);
                    this.currentParams = Object.assign({}, this.params);                    
                    this.loadSequences();
                }
            }
        },
        methods: {
            loadGene: function(gene) {
                this.currentParams.gene_descriptor_id = gene.id;
            },
            loadOtu: function(otu) {
                this.currentParams.otu_id = otu.id;
            },
            loadCollectionObjectNamespace: function(namespace) {
                this.currentParams.collection_object_namespace_id = namespace.id;
            },
            getGeneInput: function(input) {
                this.currentParams.gene_descriptor_id = null;
            },
            getOtuInput: function(input) {
                this.currentParams.otu_id = null;
            },
            getCollectionObjectNamespaceInput: function(input) {
                this.currentParams.collection_object_namespace_id = null;
            },
            findSequences: function() {
                this.currentParams.page = 1;
                this.params = Object.assign({}, this.currentParams);
                this.addPageHistory();
                this.loadSequences();
            },
            loadSequences: function() {
                let button = document.getElementById("find_button");
                button.disabled = true;

                this.$http.get(this.generateUrl("/tasks/sequence/browse/sequences", this.params)).then(res => {
                    this.list = res.body;
                    this.$refs.pagedTable.selectPage(this.params.page);
                    button.disabled = false;
                });
            },
            editSequence: (sequence) => {
                window.location.href = "/sequences/" + sequence.id;
            },
            pageSelected: function(newPage) {
                if(newPage !== this.params.page) {
                    this.currentParams.page = newPage;
                    this.params.page = newPage;
                    this.addPageHistory();
                }
            },
            addPageHistory: function() {
                history.pushState({ params: this.params }, null, this.generateUrl("/tasks/sequence/browse/index", this.params));
            },
            generateUrl: function(baseUrl, params) {
                let url = `${baseUrl}?`;

                for(let key in params)
                    if(params[key])
                        url += `${key}=${params[key]}&`;

                return url.slice(0, -1);
            }
        }
    }
</script>

<style scoped>
    #gene_autocomplete {
        margin-bottom: 5px;
    }

    #otu_descendants_checkbox {
        vertical-align: middle;
    }

    .valid-input + span::after {
        content: "✔";
        color: limegreen;
    }

    .vue-autocomplete {
        display: inline-block;
    }

    .filters-container,
    .filter-container {
        margin-bottom: 20px;
    }

    input[type=text],
    .vue-autocomplete >>> input[type=text] {
        width: 500px;
        margin-bottom: 5px;
    }
</style>
