<template>
	<div class="original-combination-picker">
		<form class="horizontal-left-content">
			<div class="button-current separate-right">
				<button  v-if="!existOriginalCombination" type="button" @click="addOriginalCombination()" class="normal-input button button-submit">Set as current</button>
			</div>
			<div>
				<draggable class="flex-wrap-column" v-model="taxonOriginal" v-if="!existOriginalCombination"
					:options="{
						animation: 150, 
						group: { 
							name: 'combination', 
							put: isGenus,
							pull: true
						},
						filter: '.item-filter'
					}">
					<div v-for="item in taxonOriginal" class="horizontal-left-content middle item-draggable">
						<input type="text" class="normal-input current-taxon" :value="item.name" disabled/>
						<span class="handle" data-icon="scroll-v"></span>
					</div>
				</draggable>
			</div>
		</form>
		<hr>
		<original-combination class="separate-top separate-bottom"
			nomenclature-group="Genus"
			@processed="saveTaxonName"
			@delete="saveTaxonName"
			@create="saveTaxonName"
			:disabled="!existOriginalCombination"
			:options="{
				animation: 150, 
				group: { 
					name: 'combination', 
						put: isGenus,
						pull: false
					},
					filter: '.item-filter'
				}"
			:relationships="genusGroup">
		</original-combination>
		<original-combination class="separate-top separate-bottom" 
			v-if="!isGenus"
			nomenclature-group="Species"
			@processed="saveTaxonName"
			@delete="saveTaxonName"
			@create="saveTaxonName"
			:disabled="!existOriginalCombination"
			:options="{
				animation: 150, 
				group: { 
					name: 'combination', 
						put: !isGenus,
						pull: false
					},
					filter: '.item-filter'
				}"
			:relationships="speciesGroup">
		</original-combination>
		<div class="original-combination separate-top separate-bottom">
			<div class="flex-wrap-column rank-name-label">
				<label class="row capitalize"></label>
			</div>
			<div v-if="existOriginalCombination" class="flex-separate middle">
				<span class="original-combination-name" v-html="taxon.original_combination"></span>
				<span class="circle-button btn-delete" @click="removeAllCombinations()"></span>
			</div>
		</div>
	</div>
</template>
<script>

	const GetterNames = require('../store/getters/getters').GetterNames;
	const ActionNames = require('../store/actions/actions').ActionNames;
  	const draggable = require('vuedraggable');
	const listEntrys = require('./listEntrys.vue').default;
  	const originalCombination = require('./originalCombination.vue').default;


	export default {
		components: {
			listEntrys,
			draggable,
			originalCombination
		},
		data: function() {
			return {
				taxonOriginal: [],
				genusGroup: {
					genus: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
					subgenus: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
				},
				speciesGroup: {
					species: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
					subspecies: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
					variety: 'TaxonNameRelationship::OriginalCombination::OriginalVariety',
					form: 'TaxonNameRelationship::OriginalCombination::OriginalForm',
				}
			}
		},
		computed: {
			taxon() {
				return this.$store.getters[GetterNames.GetTaxon]
			},
			isGenus() {
				return (this.$store.getters[GetterNames.GetTaxon].rank_string.split('::')[2] == 'GenusGroup')
			},
			existOriginalCombination: {
				get: function() { 
					let combinations = this.$store.getters[GetterNames.GetOriginalCombination]
					let exist = false;
					for (var key in combinations) {
						if(combinations[key].subject_taxon_name_id == this.taxon.id) {
							exist = true;
						}
					}
					return exist;
				}
			},
		},
		watch: {
			existOriginalCombination: {
				handler: function(newVal, oldVal) {
					if(newVal == oldVal) return true
					this.createTaxonOriginal();
				},
				immediate: true
			}
		},
		methods: {
			saveTaxonName: function() {
				var taxon_name = {
					taxon_name: this.taxon
				}
				this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon);
			},
			createTaxonOriginal: function() {
				this.taxonOriginal = [{
					name: this.$store.getters[GetterNames.GetTaxon].name, 
					value: {
						subject_taxon_name_id: this.$store.getters[GetterNames.GetTaxon].id
					}, 
					show: true, 
					autocomplete: undefined, 
					id: this.$store.getters[GetterNames.GetTaxon].id
				}]
			},
			removeAllCombinations: function() {
				let that = this;
				let combinations = this.$store.getters[GetterNames.GetOriginalCombination];
				let allDelete = [];
				for(var key in combinations) {
					allDelete.push(this.$store.dispatch(ActionNames.RemoveOriginalCombination, combinations[key]).then(response => {
						return true
					}));
				}
				Promise.all(allDelete).then(function() {
					that.saveTaxonName();
				})
			},
			addOriginalCombination: function() {
				var that = this;
				this.createCombination(this.taxon.id, this.taxon.rank);
				this.taxon.ancestor_ids.forEach(function(item) {
					let rank = item[1].split('::')[3];
					if(rank)
						that.createCombination(item[0],rank.toLowerCase());
				});	
				this.saveTaxonName();
			},
			createCombination: function(id, rank) {
				let types = Object.assign({}, this.genusGroup, this.speciesGroup);
				var data = {
					type: types[rank],
					id: id
				}
				if(data.type) {
					this.$store.dispatch(ActionNames.AddOriginalCombination, data);
				}				
			}
		}
	}
</script>
<style lang="scss">
.original-combination-picker {
	.button-current {
		width: 100px;
	}
	.current-taxon {
		width: 400px;
	}
	.original-combination-name {
		margin-right:35px;
		width: 400px;
	}
	.handle {
		width: 15px;
		background-position: center;

	}
}

</style>