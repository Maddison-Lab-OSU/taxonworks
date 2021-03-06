import { MutationNames } from '../mutations/mutations';

export default function({ commit, state }) {
	let type_material = {
		id: undefined,
		protonym_id: state.type_material.protonym_id,
		biological_object_id: undefined,
		type_type: undefined,
		roles_attributes: [],
		collection_object: {
			id: undefined,
			total: 1,
			preparation_type_id: undefined,
			repository_id: undefined,
			collecting_event_id: undefined,
			buffered_collecting_event: undefined,
			buffered_determinations: undefined,
			buffered_other_labels: undefined,
		}
	}
	commit(MutationNames.SetTypeMaterial, type_material);
}

