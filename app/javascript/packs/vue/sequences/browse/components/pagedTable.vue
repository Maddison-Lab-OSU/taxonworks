<template>
    <div>
        <paged-table-header
            ref="pagedTableHeader"
            :maxItems="list.length"
            :initialPage="initialPage"
            :perPage="perPage"
            :pagesDisplayed="pagesDisplayed"
            :title="title"
            @pageSelected="pageSelected"
            @showAll="showAll"
            @downloadAll="downloadAll">
        </paged-table-header>
        <table-list
            :list="pagedList"
            :attributes="attributes"
            :header="header"
            :destroy="destroy"
            :edit="edit"
            @delete="(item) => { $emit('delete', item); }"
            @edit="(item) => { $emit('edit', item); }">
        </table-list>
    </div>
</template>

<script>
    import pagedTableHeader from "./pagedTableHeader.vue";
    import tableList from "../../../components/table_list.vue";

    export default {
        data: function() {
            return {
                currentPage: this.initialPage,
                paginating: true
            }
        },
        props: {
            initialPage: {
                type: Number,
                default: 1
            },
            perPage: {
                type: Number,
                default: 25
            },
            pagesDisplayed: {
                type: Number,
                default: 9
            },
            title: {
                type: String,
                default: "Displaying"
            },
            list: {
				type: Array,
				default: () => { 
					return []
				}
			},
			attributes: {
				type: Array,
				required: true
			},
			header: {
				type: Array,
				default: () => {
					return []
				}
			},
			destroy: {
				type: Boolean,
				default: true
			},
			edit: {
				type: Boolean,
				default: false
			}
        },
        components: {
            pagedTableHeader,
            tableList
        },
        methods: {
            pageSelected: function(newPage) {
                this.currentPage = newPage;
                this.paginating = true;
                this.$emit("pageSelected", newPage);
            },
            showAll: function() {
                this.paginating = false;
            },
            downloadAll: function() {
                let csvContent = "data:text/csv;charset=utf-8," + this.header.join(",") + "\n";

                for(let i = 0; i < this.list.length; i++) {
                    for(let j = 0; j < this.attributes.length; j++) {
                        csvContent += this.list[i][this.attributes[j]];

                        if(j < this.attributes.length - 1)
                            csvContent += ",";
                    }

                    csvContent += "\n";
                }

                let encodedUri = encodeURI(csvContent);
                let link = document.createElement("a");
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", "data.csv");
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            },
            selectPage: function(newPage) {
                this.$refs.pagedTableHeader.selectPage(newPage);
            }
        },
        computed: {
            pagedList: function() {
                if(this.paginating) {
                    const begIndex = this.perPage * (this.currentPage - 1);
                    return this.list.slice(begIndex, begIndex + this.perPage);
                }

                else
                    return this.list;
            }
        }
    }
</script>
