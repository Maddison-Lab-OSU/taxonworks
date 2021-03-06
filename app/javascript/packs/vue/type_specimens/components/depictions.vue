<template>
  <div class="depiction-container">
    <spinner v-if="false" :show-spinner="false" legend="Create a type specimen to upload images"></spinner>
    <dropzone class="dropzone-card separate-bottom" v-on:vdropzone-sending="sending" v-on:vdropzone-file-added="addedfile" v-on:vdropzone-success="success" ref="depiction" id="depiction" url="/depictions" :useCustomDropzoneOptions="true" :dropzoneOptions="dropzone"></dropzone>
    <div class="flex-wrap-row" v-if="figuresList.length">
      <depictionImage v-for="item in figuresList" 
        @delete="removeDepiction"
        :key="item.id"
        :depiction="item">
      </depictionImage>
    </div>
  </div>

</template>

<script>

  import ActionNames from '../store/actions/actionNames';
  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';
  import { GetDepictions, DestroyDepiction } from '../request/resources';

  import dropzone from '../../components/dropzone.vue';
  import expand from './expand.vue';
  import spinner from '../../components/spinner.vue';
  import depictionImage from './depictionImage.vue';
  
  export default {
    components: {
      depictionImage,
      dropzone,
      expand,
      spinner
    },
    computed: {
      getTypeMaterial() {
        return this.$store.getters[GetterNames.GetTypeMaterial]
      },
      getImages() {
        return this.$store.getters[GetterNames.GetTypeMaterial].collection_object.images
      }
    },
    data: function() {
      return {
        creatingType: false,
        displayBody: true,
        figuresList: [],
        dropzone: {
          paramName: "depiction[image_attributes][image_file]",
          url: "/depictions",
          autoProcessQueue: false,
          headers: {
            'X-CSRF-Token' : document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          },
          dictDefaultMessage: "Drop images here to add figures",
          acceptedFiles: "image/*"
        },
      }
    },
    watch: {
      getTypeMaterial(newVal, oldVal) {
        if(newVal.id && (newVal.id != oldVal.id)) {
          this.$refs.depiction.setOption('autoProcessQueue', true)
          GetDepictions(newVal.collection_object.id).then(response => {
            this.figuresList = response;
          })
        }
        else {
          this.figuresList = [];
          this.$refs.depiction.setOption('autoProcessQueue', false)
        }
      }
    },
    methods: {
      'success': function(file, response) {
        this.figuresList.push(response);
        this.$refs.depiction.removeFile(file);
      },
      'sending': function(file, xhr, formData) {
        formData.append("depiction[depiction_object_id]", this.getTypeMaterial.collection_object.id);
        formData.append("depiction[depiction_object_type]", 'CollectionObject');
      },
      'addedfile': function() {
        if(!this.getTypeMaterial.id && !this.creatingType) {
          this.creatingType = true;
          this.$store.dispatch(ActionNames.CreateTypeMaterial).then((response) => {
            var that = this;
            setTimeout(function() {
              that.$refs.depiction.setOption('autoProcessQueue', true);
              console.log(response);
              that.$refs.depiction.processQueue();
              that.creatingType = false;
            },500)
          }, () => {
            this.creatingType = false;
          })
        }
      },
      removeDepiction(depiction) {
        if(window.confirm(`Are you sure want to proceed?`)) {
          DestroyDepiction(depiction.id).then(response => {
            TW.workbench.alert.create('Depiction was successfully deleted.', 'notice');
            this.figuresList.splice(this.figuresList.findIndex((figure) => { return figure.id == depiction.id }), 1);
          });
        }        
      }
    }
  }
</script>
<style scoped>
  .depiction-container {
    width: 500px;
    max-width: 500px;
  }
</style>