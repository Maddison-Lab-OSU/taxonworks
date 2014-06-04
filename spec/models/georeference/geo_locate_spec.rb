require 'spec_helper'

describe Georeference::GeoLocate do

  let(:geo_locate) { FactoryGirl.build(:georeference_geo_locate)}
  let(:request_params) { {country: 'USA', locality: 'Champaign', state: 'IL', doPoly: 'true', locality: 'Urbana'} }
  let(:request) { Georeference::GeoLocate::Request.new(request_params) }
  let(:response) { request.response }
  let(:georeference_from_build) { Georeference::GeoLocate.build(request_params) } 

  
   context 'building a Georeference::GeoLocate' do
    before(:each) {
      @a = Georeference::GeoLocate.build(request_params) 
    }

    specify '#build builds a Georeference::Geolocate instance' do
      expect(@a.class).to eq(Georeference::GeoLocate)
    end

    specify '#build(request_params) passes' do
      expect(Georeference::GeoLocate.build(request_params)).to be_true
    end

    specify 'with a collecting event #build produces a valid instance' do
      @a.collecting_event = FactoryGirl.build(:valid_collecting_event) 
      expect(@a.valid?).to be_true
    end

    specify 'a built, valid, instance is geometrically(?) correct' do
      @a.collecting_event = FactoryGirl.build(:valid_collecting_event) 
      expect(@a.save).to be_true
      expect(@a.error_geographic_item.geo_object.contains?(@a.geographic_item.geo_object)).to be_true
    end

    specify 'with invalid parameters returns a Georeference::GeoLocate instance with errors on :base' do
      pending
    end

    specify '#with doPoly false instance should have no error polygon' do
      pending
    end

    # TODO: what was the 3 reason again?
    specify 'with doUncert false error_radius should be 3(?)' do
      pending
    end
   end 
  
  context 'instance methods' do
    specify 'api_response=(response) populates .geographic_item' do  
      expect(geo_locate.api_response = response).to be_true
      expect(geo_locate.geographic_item).not_to be_nil
    end

    specify 'api_response=(response.result) populates .error_geographic_item' do 
      expect(geo_locate.api_response = response).to be_true
      expect(geo_locate.error_geographic_item).not_to be_nil
      expect(geo_locate.error_radius.to_i > 5000).to be_true  # Bad test
    end

    specify '.request_hash' do
      expect(georeference_from_build.request_hash.to_s).to eq('{"country"=>"USA", "state"=>"IL", "county"=>"", "locality"=>"Urbana", "hwyX"=>"false", "enableH2O"=>"false", "doUncert"=>"true", "doPoly"=>"true", "displacePoly"=>"false", "languageKey"=>"0", "fmt"=>"json"}')
    end
  end




  context 'Request' do
    specify 'has a @response' do
      expect(request.respond_to?(:response)).to be_true
    end

    specify 'has @request_params' do
      expect(request.request_params).to eq(Georeference::GeoLocate::REQUEST_PARAMS.merge(request_params))
    end

    specify 'has @request_param_string' do
      expect(request.request_param_string).to be(nil)
    end

    specify '.build_param_string' do # '.make_request builds a request string' do
      expect(request.build_param_string).to be_true
      expect(request.request_param_string).to eq('country=USA&state=IL&county=&locality=Urbana&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json')
    end

    specify '.locate' do
      expect(request.locate).to be_true
    end

    specify '.locate populates @response' do
      expect(request.locate).to be_true
      expect(request.response).to_not be_nil
      expect(request.response.class).to eq(Georeference::GeoLocate::Response)
    end

    specify '.succeeded?' do
      expect(request.locate).to be_true
      expect(request.succeeded?).to be_true
    end
  end


  context 'Response' do
    specify 'contains some @result (in json)' do
      request.locate
      expect(response.result.keys.include?('numResults')).to be_true 
    end
  end

end
