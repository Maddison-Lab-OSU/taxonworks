<template>
  <div class="panel type-specimen-box">
    <spinner :show-spinner="false" :show-legend="false" v-if="!(protonymId && type)"></spinner>
    <div class="header flex-separate middle">
        <h3>Collection object</h3>
        <div class="flexbox middle">
          <radial-annotator v-if="typeMaterial.id" :globalId="getCollectionObject.global_id"></radial-annotator>
          <expand v-model="displayBody"></expand>
        </div>
    </div>
    <div class="body" v-if="displayBody">
      <div class="switch-radio field">
        <template v-for="item, index in tabOptions">
          <input 
            v-model="view"
            :value="item"
            :id="`switch-picker-${index}`" 
            name="switch-picker-options"
            type="radio"
            class="normal-input button-active" 
          />
          <label :for="`switch-picker-${index}`" class="capitalize">{{ item }}</label>
        </template>
      </div>
      <div class="flex-separate">
        <div>

          <collection-object 
            v-if="view == 'new'" 
            @send="createTypeMaterial">
          </collection-object>

          <collection-object 
            v-if="view == 'edit'" 
            @send="updateCollectionObject">
          </collection-object>

          <template v-if="view == 'existing'">

            <div class="field">
              <label>Collection object</label>
              <autocomplete
                class="types_field"
                url="/collection_objects/autocomplete"
                param="term"
                label="label_html"
                :sendLabel="getOwnPropertyNested(typeMaterial, 'collection_object', 'object_tag')"
                @getItem="biologicalId = $event.id; (typeMaterial.id ? updateTypeMaterial() : createTypeMaterial())"
                display="label"
                min="2">
              </autocomplete>
            </div>

          </template>
        </div>
        <div class="field" v-if="protonymId">
          <label>Depiction</label>
          <depictions-section></depictions-section>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';
  import ActionNames from '../store/actions/actionNames';

  import autocomplete from '../../components/autocomplete.vue';
  import radialAnnotator from '../../components/annotator/annotator.vue';
  import spinner from '../../components/spinner.vue';
  import expand from './expand.vue';
  import collectionObject from './collectionObject.vue';
  import toggleSwitch from './toggleSwitch.vue';
  import depictionsSection from './depictions.vue';
  
  export default {
    components: {
      depictionsSection,
      collectionObject,
      autocomplete,
      expand,
      toggleSwitch,
      radialAnnotator,
      spinner
    },
    computed: {
      typeMaterial() {
        return this.$store.getters[GetterNames.GetTypeMaterial]
      },
      getCollectionObject() {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      protonymId: {
        get() {
          return this.$store.getters[GetterNames.GetProtonymId];
        },
        set(value) {
          this.$store.commit(MutationNames.SetProtonymId, value);
        }
      },
      type: {
        get() {
          return this.$store.getters[GetterNames.GetType];
        },
        set(value) {
          this.$store.commit(MutationNames.SetType, value);
        }
      },
      biologicalId: {
        get() {
          return this.$store.getters[GetterNames.GetBiologicalId]
        },
        set(value) {
          this.$store.commit(MutationNames.SetBiologicalId, value)
        }
      },
      view: {
        get() {
          return this.$store.getters[GetterNames.GetSettings].materialTab
        },
        set(value) {
          this.$store.commit(MutationNames.SetMaterialTab, value)
        }
      }
    },
    data: function() {
      return {
        tabOptions: ['new', 'existing'],
        displayBody: true,
        roles_attribute: [],
      }
    },
    watch: {
      typeMaterial(newVal) {
        if(newVal.id) {
          this.view = 'edit';
          this.tabOptions = ['edit', 'existing']
        }
        else {
          this.tabOptions = ['new', 'existing']
        }
      }
    },
    methods: {
      createTypeMaterial() {
        this.$store.dispatch(ActionNames.CreateTypeMaterial);
      },
      updateTypeMaterial() {
        let type_material = this.$store.getters[GetterNames.GetTypeMaterial];
        this.$store.dispatch(ActionNames.UpdateTypeSpecimen, { type_material: type_material });
      },
      updateCollectionObject() {
        let type_material = this.$store.getters[GetterNames.GetTypeMaterial];
        this.$store.dispatch(ActionNames.UpdateCollectionObject, { type_material: type_material })
      },
      getOwnPropertyNested(obj) {
        var args = Array.prototype.slice.call(arguments, 1);

        for (var i = 0; i < args.length; i++) {
          if (!obj || !obj.hasOwnProperty(args[i])) {
            return undefined;
          }
          obj = obj[args[i]];
        }
        return obj;
      }
    }
  }
</script>
<style scoped>
  .switch-radio label {
      width: 100px;
  }
</style>