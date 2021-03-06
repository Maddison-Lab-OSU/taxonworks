var TW = TW || {};
TW.views = TW.views || {};
TW.views.tags = TW.views.tags || {};
TW.views.tags.tag_icon = TW.views.tags.tag_icon || {};

Object.assign(TW.views.tags.tag_icon, {

	objectElement: undefined,
	CTVCount: 0,
	toolTip: undefined,
	isTagged: undefined,

	init: function(element) {

		var that = this;
		this.objectElement = element;
		if(this.getDefault()) {
			this.CTVCount = $(element).attr('data-inserted-keyword-count');
			if($(element).attr('data-default-tagged-id') == "false") {
				this.isTagged = false;
				that.setAsCreate(element);
			}
			else {
				this.isTagged = true;
				that.setAsDelete(element, $(this).attr('data-default-tagged-id'));
			}
		}
		else {
			this.setAsDisable(element);
		}

		$(this).removeAttr('data-is-default-tagged');

		$(document).on('pinboard:insert', function(event) {
			if(event.detail.type === "ControlledVocabularyTerm") {
				that.checkExist(that.objectElement);
			}
		});

		$(document).on('tag:update', function(event) {
			that.checkExist(that.objectElement);
		});

		$(document).on('tag:create', function(event) {
			that.CTVCount = event.detail.keyword_count;
			$(that.objectElement).attr('title', '<p>Remove ' + that.getDefaultString() + ' tag</p>' + that.createCountLabel());
			that.createTooltip(that.objectElement);
		});

		$(document).on('tag:delete', function(event) {
			that.CTVCount = event.detail.keyword_count;
			$(that.objectElement).attr('title', '<p>Remove ' + that.getDefaultString() + ' tag</p>' + that.createCountLabel());
			that.createTooltip(that.objectElement);
		});

		$(element).on('click', function() {
			if(!$(this).hasClass('btn-disabled')) {
				if($(this).hasClass('btn-tag-add')) {
					that.createTag($(this).attr('data-tag-object-global-id'), that.getDefault()).then(response => {
						TW.workbench.alert.create('Tag was successfully updated.', 'notice')
						that.CTVCount++;
						that.setAsDelete(this, response.id);
						that.eventTag('tag:create', that.CTVCount);
					});
				}
				else {
					if($(this).attr('data-default-tagged-id')) {
						that.deleteTag($(this).attr('data-tag-object-global-id'), $(this).attr('data-default-tagged-id')).then(response => {
							TW.workbench.alert.create('Tag was successfully removed.','notice')
							that.CTVCount--;
							that.setAsCreate(this);
							that.eventTag('tag:delete', that.CTVCount);
						});
					}
				}
			}
		});
	},

	eventTag: function(event, count) {
		var event = new CustomEvent(event, {
		  detail: {
		  	keyword_count: count
		  }
		});
		document.dispatchEvent(event);
	},

	createTooltip: function(element) {
		if(this.toolTip && this.toolTip.getReferenceData(element || this.toolTip.getPopperElement(this.objectElement))) {
			this.toolTip.update(this.toolTip.getPopperElement(this.objectElement))
		}
		else {
			this.toolTip = tippy(element, {
				position: 'bottom',
				animation: 'scale',
				inertia: true,
				size: 'small',
				arrowSize: 'small',
				arrow: true
			})
		}

	},

	makeAjaxCall: function(type, url, data) {
		return new Promise(function(resolve, reject) {
			$('body').mx_spinner();
			$.ajax({
			    url: url,
			    type: type,
			    data: data,
			    dataType: 'json',
			    success: function(data) {
			        return resolve(data);
			    },
			    complete: function() {
			    	$('body').mx_spinner('hide');
			    }
			});
		});
	},

	createTag: function(globalId, keyId) {
		var url = '/tags';
		var tag = {
			tag: {
				keyword_id: keyId,
				annotated_global_entity: globalId
			}
		}
		return this.makeAjaxCall('POST', url, tag);
	},

	deleteTag: function(globalId, tagId) {
		
		var url = '/tags/' + tagId;
		var tag = {
			tag: {
				annotated_global_entity: globalId,
				_destroy: true
			}
		}
		return this.makeAjaxCall('DELETE', url, tag);

	},

	createCountLabel: function() {
		return '<p>Used already on '+ this.CTVCount +' objects</p>';
	},

	setAsDelete: function(element, tagId) {
		$(element).attr('title', '<p>Remove ' + this.getDefaultString() + ' tag</p>' + this.createCountLabel());
		$(element).removeClass('btn-disabled');
		$(element).removeClass('btn-tag-add');
		$(element).addClass('circle-button');
		$(element).addClass('btn-tag-delete');
		$(element).attr('data-default-tagged-id', tagId);
		this.createTooltip(element);
	},

	setAsCreate: function(element) {
		$(element).attr('title', '<p>Create tag: ' + this.getDefaultString() + '</p>'+ this.createCountLabel());
		$(element).removeClass('btn-disabled');
		$(element).removeClass('btn-tag-delete');
		$(element).removeAttr('data-default-tagged-id');
		$(element).addClass('circle-button');
		$(element).addClass('btn-tag-add');
		this.createTooltip(element);
	},

	setAsDisable: function(element) {
		$(element).attr('title', '<p>Select a default CVT first.</p>');
		$(element).addClass('btn-tag-add');
		$(element).addClass('btn-disabled');
		$(element).removeAttr('data-default-tagged-id');
		this.createTooltip(element);
	},

	getCVTCount: function(id) {
		var that = this;
		return this.makeAjaxCall('GET', '/controlled_vocabulary_terms/'+ id, '').then(response => {
			return response.tag_count;
		});
	},

	checkExist: function(element) {
		var globalId = $(element).attr('data-tag-object-global-id');
		var defaultTag = this.getDefault();
		var that = this;

		if(defaultTag) {
			var url = "/tags/exists?global_id=" + globalId + "&keyword_id=" + defaultTag;

			this.getCVTCount(defaultTag).then(response => {
				that.CTVCount = response;
				$.get(url, function(data) {
					if(data) {
						that.setAsDelete(element, data.id);
					}
					else {
						that.setAsCreate(element);
					}				
				});
			});
		}
		else {
			this.setAsDisable(element);
		}
	},
	getDefaultString: function() {
		return $('[data-pinboard-section="ControlledVocabularyTerms"] [data-insert="true"] a')[0].textContent;
	},

	getDefault: function() {
		return $('[data-pinboard-section="ControlledVocabularyTerms"] [data-insert="true"]').attr('data-pinboard-object-id');
	}
});

$(document).on('turbolinks:load', function() {
	if($(".default_tag_widget").length) {
		var newTags = [];
		$(".default_tag_widget").each(function() {
	  		tag = Object.assign({}, TW.views.tags.tag_icon);
	  		tag.init(this);
	  		newTags.push(tag);
		})
	}
});