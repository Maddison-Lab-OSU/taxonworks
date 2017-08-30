const MutationNames = {
	AddTaxonStatus: 'addTaxonStatus',
	AddTaxonRelationship: 'addTaxonRelationship',
	AddOriginalCombination: 'addOriginalCombination',
	RemoveTaxonStatus: 'removeTaxonStatus',
	RemoveTaxonRelationship: 'removeTaxonRelationship',
	RemoveOriginalCombination: 'removeOriginalCombination',
	SetModalStatus: 'setModalStatus',
	SetModalType: 'setModalType',
	SetModalRelationship: 'setModalRelationship',
	SetAllRanks: 'setAllRanks',
	SetParent: 'setParent',
	SetParentId: 'setParentId',
	SetRankClass: 'setRankClass',
	SetRankList: 'setRankList',
	SetParentRankGroup: 'setParentRankGroup',
	SetRelationshipList: 'setRelationshipList',
	SetTaxonRelationshipList: 'setTaxonRelationshipList',
	SetStatusList: 'setStatusList',
	SetTaxonRelationship: 'setTaxonRelationship',
	SetTaxonType: 'setTaxonType',
	SetTaxonStatusList: 'setTaxonStatusList',
	SetTaxonAuthor: 'setTaxonAuthor',
	SetTaxonMasculine: 'setTaxonMasculine',
	SetTaxonFeminine: 'setTaxonFeminine',
	SetTaxonNeuter: 'setTaxonNeuter',
	SetTaxonName: 'setTaxonName',
	SetTaxonId: 'setTaxonId',
	SetTaxon: 'setTaxon',
	SetRoles: 'setRoles',
	SetCitation: 'setCitation',
	SetEtymology: 'setEtymology',
	SetSoftValidation: 'setSoftValidation',
	SetHardValidation: 'setHardValidation',
	SetTaxonYearPublication: 'setTaxonYearPublication',
	SetOriginalCombination: 'setOriginalCombination',
	SetNomenclaturalCode: 'setNomenclaturalCode',
	UpdateLastChange: 'updateLastChange',
	UpdateLastSave: 'updateLastSave'
};

const MutationFunctions = {
	[MutationNames.AddTaxonStatus]: require('./addTaxonStatus'),
	[MutationNames.AddTaxonRelationship]: require('./addTaxonRelationship'),
	[MutationNames.AddOriginalCombination]: require('./addOriginalCombination'),
	[MutationNames.RemoveTaxonStatus]: require('./removeTaxonStatus'),
	[MutationNames.RemoveTaxonRelationship]: require('./removeTaxonRelationship'),
	[MutationNames.RemoveOriginalCombination]: require('./removeOriginalCombination'),
	[MutationNames.SetModalStatus]: require('./setModalStatus'),
	[MutationNames.SetModalType]: require('./setModalType'),
	[MutationNames.SetTaxonType]: require('./setTaxonType'),
	[MutationNames.SetModalRelationship]: require('./setModalRelationship'),
	[MutationNames.SetAllRanks]: require('./setAllRanks'),
	[MutationNames.SetParent]: require('./setParent'),
	[MutationNames.SetParentId]: require('./setParentId'),
	[MutationNames.SetRelationshipList]: require('./setRelationshipList'),
	[MutationNames.SetRankClass]: require('./setRankClass'),
	[MutationNames.SetRankList]: require('./setRankList'),
	[MutationNames.SetStatusList]: require('./setStatusList'),
	[MutationNames.SetTaxonStatusList]: require('./setTaxonStatusList'),
	[MutationNames.SetTaxonRelationship]: require('./setTaxonRelationship'),
	[MutationNames.SetTaxonRelationshipList]: require('./setTaxonRelationshipList'),
	[MutationNames.SetTaxonAuthor]: require('./setTaxonAuthor'),
	[MutationNames.SetTaxonMasculine]: require('./setTaxonMasculine'),
	[MutationNames.SetTaxonFeminine]: require('./setTaxonFeminine'),
	[MutationNames.SetTaxonNeuter]: require('./setTaxonNeuter'),
	[MutationNames.SetTaxonName]: require('./setTaxonName'),
	[MutationNames.SetTaxonId]: require('./setTaxonId'),
	[MutationNames.SetTaxon]: require('./setTaxon'),
	[MutationNames.SetRoles]: require('./setRoles'),
	[MutationNames.SetCitation]: require('./setCitation'),
	[MutationNames.SetEtymology]: require('./setEtymology'),
	[MutationNames.SetSoftValidation]: require('./setSoftValidation'),
	[MutationNames.SetHardValidation]: require('./setHardValidation'),
	[MutationNames.SetParentRankGroup]: require('./setParentRankGroup'),
	[MutationNames.SetTaxonYearPublication]: require('./setTaxonYearPublication'),
	[MutationNames.SetOriginalCombination]: require('./setOriginalCombination'),
	[MutationNames.SetNomenclaturalCode]: require('./setNomenclaturalCode'),
	[MutationNames.UpdateLastChange]: require('./updateLastChange'),
	[MutationNames.UpdateLastSave]: require('./updateLastSave'),
};

module.exports = {
	MutationNames,
	MutationFunctions
};
