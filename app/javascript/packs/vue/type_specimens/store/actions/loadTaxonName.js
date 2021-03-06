import { MutationNames } from '../mutations/mutations';
import { GetTypeMaterial, GetTaxonName } from '../../request/resources';

export default function({ commit, state }, id) {
	return new Promise((resolve, rejected) => {
		commit(MutationNames.SetLoading, true);
		GetTaxonName(id).then(response => {
			commit(MutationNames.SetProtonymId, id);
			commit(MutationNames.SetTaxon, response);
			return resolve(response)
		}, () => {
			commit(MutationNames.SetLoading, false);
			return rejected();
		})
	});
};