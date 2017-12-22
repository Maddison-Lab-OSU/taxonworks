<template>
    <div id="browse_sequences">
        <div id="criteria_container">
            <div id="gene_name">
                <autocomplete
                    id="gene_autocomplete"
                    url="/descriptors/autocomplete" 
                    param="term" 
                    min="1" 
                    label="label"
                    placeholder="Enter Gene name"
                    @getItem="loadGene">
                </autocomplete>
            </div>
            <div id="otu">
                <autocomplete
                    id="otu_autocomplete"
                    url="/otus/autocomplete"
                    param="term"
                    min="3"
                    label="label"
                    placeholder="Enter Otu name"
                    @getItem="loadOtu">
                </autocomplete>
            </div>
            <div id="collection_object_namespace">
                <autocomplete
                    id="namespace_autocomplete"
                    url="/namespaces/autocomplete"
                    param="term"
                    min="1"
                    label="label"
                    placeholder="Enter namespace"
                    @getItem="loadCollectionObjectNamespace">
                </autocomplete>
                <input type="text" v-model="collection_object_identifier">
            </div>
            <div id="search_button">
                <input id="find_button" type="submit" @click="findSequences" class="button-request">
            </div>
        </div>
        <paged-table
            title="Displaying sequences"
            :list="list"
            :header="header"
            :attributes="attributes"
            :edit="true"
            :destroy="false"
            @edit="editSequence">
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
                gene_descriptor: {},
                otu: {},
                collection_object_namespace: {},
                collection_object_identifier: '',
                list: [],
                header: [
                    "Name"
                ],
                attributes: [
                    "name"
                ]
            }
        },
        methods: {
            loadGene: function (gene) {
                this.gene_descriptor = gene;
            },
            loadOtu: function(otu) {
                this.otu = otu;
            },
            loadCollectionObjectNamespace: function(namespace) {
                this.collection_object_namespace = namespace;
            },
            findSequences: function() {
                let button = document.getElementById("find_button");
                button.disabled = true;

                this.$http.get("/tasks/sequence/browse/sequences", { params: this.params }).then(res => {
                    this.list = res.body;
                    button.disabled = false;
                });
            },
            editSequence: (sequence) => {
                window.location.href = "/sequences/" + sequence.id;
            }
        },
        computed: {
            params: function() {
                return {
                    otu_id: this.otu.id,
                    otu_descendants: 1,
                    collection_object_namespace_id: this.collection_object_namespace.id,
                    collection_object_identifier: this.collection_object_identifier,
                    gene_descriptor_id: this.gene_descriptor.id
                }
            }
        }
    }
</script>

<style scoped>
    #gene_autocomplete {
        margin-bottom: 5px;
    }
</style>
