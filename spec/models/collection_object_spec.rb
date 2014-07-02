require 'spec_helper'

describe CollectionObject do

  let(:collection_object) {FactoryGirl.build(:collection_object) }

  context 'validation' do
    specify 'require type' do
      collection_object.valid?
      expect(collection_object.errors.include?(:type)).to be_truthy
    end

    specify 'both total and ranged_lot_category_id can not be present' do
      collection_object.total = 10
      collection_object.ranged_lot_category_id = 10
      expect(collection_object.valid?).to be_falsey
      expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
    end 
  end

  context 'associations' do
    context 'belongs_to' do
      specify 'preparation_type' do
        expect(collection_object).to respond_to(:preparation_type)
      end

      specify 'repository' do
        expect(collection_object).to respond_to(:repository)
      end

      specify 'collecting_event' do
        expect(collection_object).to respond_to(:collecting_event)
      end

      specify 'preparation_type' do
        expect(collection_object).to respond_to(:preparation_type)
      end
    end
  end

  context 'incoming data can be stored in buffers' do
    specify 'buffered_collecting_event' do
      expect(collection_object).to respond_to(:buffered_collecting_event) 
    end

    specify 'buffered_determination' do
      expect(collection_object).to respond_to(:buffered_determinations)
    end

    specify 'buffered_other_labels' do
      expect(collection_object).to respond_to(:buffered_other_labels)
    end
  end

  context 'general functionality' do
    it "should return the repository"
    it "should permit arbitrary requirable properties (key/value pairs)"
    it "on update it should SCREAM AT YOU when you change implied data if more than one biological_collection_object uses that data" 
  end

  context 'attributes' do
    specify "current_location (the present location [time axis])" 
    specify "disposition ()"  # was boolean lost or not
    specify "destroyed? (gone, for real, never ever EVER coming back)"
    specify "condition (damaged/level)"
    specify "accession source (from whom the biological_collection_object came)"
    specify "deaccession recipient (to whom the biological_collection_object went)"
    specify "depository (where the)"  
  end

  describe "validation" do
    specify "once set, a verbatim label can not change" # DDA: not a good idea, students may have questions, after which the label could be updated
  end

  context 'soft validation' do
    context 'accession fields are missing' do
      specify 'accessioned_at is missing' do
        o = Specimen.new(accession_provider_id: 1)
        o.soft_validate(:missing_accession_fields)
        expect(o.soft_validations.messages_on(:accessioned_at).count).to eq(1)
      end
      specify 'accession_recipient_id is missing' do
        o = Specimen.new(accessioned_at: '2014-06-02')
        o.soft_validate(:missing_accession_fields)
        expect(o.soft_validations.messages_on(:accession_provider_id).count).to eq(1)
      end
    end
    context 'deaccession fields are missing' do
      specify 'deaccessioned_at and deaccession_reason are missing' do
        o = Specimen.new(deaccession_recipient_id: 1)
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:deaccession_at).count).to eq(1)
        expect(o.soft_validations.messages_on(:deaccession_reason).count).to eq(1)
      end
      specify 'deaccessioned_at and deaccession_reason are missing' do
        o = Specimen.new(deaccession_reason: 'gift')
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:deaccession_at).count).to eq(1)
        expect(o.soft_validations.messages_on(:deaccession_recipient_id).count).to eq(1)
      end
    end
  end


  context 'concerns' do
    it_behaves_like "identifiable" 
    it_behaves_like "containable"
    it_behaves_like "notable"
    it_behaves_like "data_attributes"
    it_behaves_like "taggable"

    specify "locatable (location)"
    specify "figurable (images)"

  end
end
