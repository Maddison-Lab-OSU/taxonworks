require 'spec_helper'

describe Georeference do

  #grgl = Georeference::GeoLocate.new()
  #grvd = Georeference::VerbatimData.new()

  let(:georeference) { FactoryGirl.build(:georeference) }
  let(:valid_georeference) { FactoryGirl.build(:valid_georeference) }
  let(:valid_georeference_geo_locate) { FactoryGirl.build(:valid_georeference_geo_locate) }
  let(:valid_georeference_verbatim_data) { FactoryGirl.build(:valid_georeference_verbatim_data) }

  let(:request_params) {
    {country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}
  }

  context 'validation' do
    before(:each) {
      # the 'nothing special, not even valid' georeference
      georeference.save
    }

    specify '#geographic_item is required' do
      expect(georeference.errors.keys.include?(:geographic_item)).to be_true
    end
    specify '#collecting_event is required' do
      expect(georeference.errors.keys.include?(:collecting_event)).to be_true
    end
    specify '#type is required' do
      expect(georeference.errors.keys.include?(:type)).to be_true
    end
    specify "#error_geographic_item is not required" do
      # <- what did we conclude if no error is provided, just nil? -> will cause issues if so for calculations
      #pending 'setting error distance to 3 meters if not provided'
      expect(georeference.errors.keys.include?(:error_geographic_item)).not_to be_true
    end
    specify 'error_radius is not required' do
      expect(georeference.errors.keys.include?(:error_radius)).to be_false
    end
    specify 'error_depth is not required' do
      expect(georeference.errors.keys.include?(:error_depth)).to be_false
    end

    context 'legal values' do
      before(:each) {
        georeference.error_radius = 30000000
        georeference.error_depth  = 9000
        @e_g_i                    = GeographicItem.new(polygon: BOX_1)
        @area_d                   = GeographicItem.new(polygon: BOX_4)
        @g_a                      = GeographicArea.new(name:        'Box_4',
                                                       data_origin: 'Test Data',
                                                       neID:        'TD-000',
                                                       parent:      FactoryGirl.build(:earth_geographic_area),
                                                       ne_geo_item: @area_d)

        # this collecting event should produce a georeference.geographic_item.geo_object of 'Point(0.1 0.1 0.1)'
        @point0                   = GeographicItem.new(point: POINT0)
        #@point1w                  = GeographicItem.new(point: RSPEC_GEO_FACTORY.point(-1, 0))
        #@point1n                  = GeographicItem.new(point: RSPEC_GEO_FACTORY.point(0, 1))
        #@point10w                 = GeographicItem.new(point: RSPEC_GEO_FACTORY.point(-10, 0))
        #@point10n                 = GeographicItem.new(point: RSPEC_GEO_FACTORY.point(0, 10))
        @point90n                 = GeographicItem.new(point: RSPEC_GEO_FACTORY.point(0, 90))
        @point89n                 = GeographicItem.new(point: RSPEC_GEO_FACTORY.point(0, 45))
        @c_e                      = CollectingEvent.new(geographic_area:    @g_a,
                                                        verbatim_locality:  'Test Event',
                                                        minimum_elevation:  0.1,
                                                        verbatim_latitude:  '0.1',
                                                        verbatim_longitude: '0.1')

        @point0.save!
        #@point1w.save!
        #@point1n.save!
        #@point10w.save!
        #@point10n.save!
        @point90n.save!
        @point89n.save!

        #result = @point0.geo_object.distance(@point1w.geo_object)
        #result = GeographicItem.select_distance_with_geo_object('point', @point0).excluding(@point0).to_a
      }

      specify '#error_radius is < some Earth-based limit' do
        # 12,400 miles, 20,000 km
        #pending 'setting error radius to some reasonable distance'
        georeference.valid?
        expect(georeference.save).to be_false # many other reasons
        expect(georeference.errors.keys.include?(:error_radius)).to be_true

        georeference.error_radius = 3
        expect(georeference.save).to be_false # many other reasons
        expect(georeference.errors.keys.include?(:error_radius)).to be_false

      end

      specify '#error_depth is < some Earth-based limit' do
        # 8,800 meters
        #pending 'setting error depth to some reasonable distance'
        expect(georeference.save).to be_false # many other reasons
        expect(georeference.errors.keys.include?(:error_depth)).to be_true

        georeference.error_depth = 3
        expect(georeference.save).to be_false # many other reasons
        expect(georeference.errors.keys.include?(:error_depth)).to be_false

      end

      specify 'errors which result from badly formed error_geographic_item values' do
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_geographic_item: GeographicItem.new(polygon: POLY_E1))
        georeference.save
        expect(georeference.errors.keys.include?(:error_geographic_item)).to be_true
        expect(georeference.errors.keys.include?(:collecting_event)).to be_true

      end

      specify 'errors which result from badly formed error_radius values' do
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_radius: 16000,
                                                      error_geographic_item: @e_g_i)
        georeference.save
        expect(georeference.errors.keys.include?(:error_geographic_item)).to be_true
        expect(georeference.errors.keys.include?(:error_radius)).to be_true

      end

      specify 'errors which result from badly formed collecting_event area values and error_geographic_item' do
        @area_d = GeographicItem.new(polygon: POLY_E1)
        @g_a.ne_geo_item = @area_d
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_geographic_item: @e_g_i)
        expect(@c_e.geographic_area.default_geographic_item.save).to be_true
        georeference.save
        expect(georeference.errors.keys.include?(:error_geographic_item)).to be_true
        expect(georeference.errors.keys.include?(:geographic_item)).to be_true
        expect(georeference.errors.keys.include?(:collecting_event)).to be_true

      end

      specify 'errors which result from badly formed collecting_event area values and error_radius' do
        @area_d = GeographicItem.new(polygon: POLY_E1)
        @g_a.ne_geo_item = @area_d
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_radius:     160000)
        expect(@c_e.geographic_area.default_geographic_item.save).to be_true
        georeference.save
        expect(georeference.errors.keys.include?(:error_radius)).to be_true
        expect(georeference.errors.keys.include?(:geographic_item)).to be_true
        expect(georeference.errors.keys.include?(:collecting_event)).to be_true

      end

      specify 'error_geographic_item.geo_object, when provided, should contain geographic_item.geo_object' do
        # case 1
        #   GeoRef    A (POINT0)
        #   GeoItem   B (BOX_B)
        #pending 'validation of the accceptability of the error geo_object, if provided'
        #
        # building up a georeference:
        #
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_geographic_item: @e_g_i)
        georeference.save
        expect(georeference.error_geographic_item.contains?(georeference.geographic_item)).to be_true
      end

      specify '.error_box with error_radius returns a key-stone' do
        # case 2a - radius
        georeference = Georeference::VerbatimData.new(collecting_event: @c_e,
                                                      error_radius:     160000)
        # TODO: Figure out why the save of the georeference does not propagate down to the geographic_item which is part of the geographic_area.
        # here, we make sure the geographic_item gets saved.
        expect(@c_e.geographic_area.default_geographic_item.save).to be_true
        georeference.save
        # TODO: the following expectation will not be met, under some circumstances (different math packages on different operating systems), and has been temporarily disabled
        #expect(georeference.error_box?.to_s).to eq('POLYGON ((-1.344521043156894 1.5469896879975282 0.0, 1.5445210431568939 1.5469896879975282 0.0, 1.5445210431568939 -1.3469896879975283 0.0, -1.344521043156894 -1.3469896879975283 0.0, -1.344521043156894 1.5469896879975282 0.0))')
        expect(georeference.error_box?.to_s).to start_with 'POLYGON ((-1.34452104315689'
      end

      specify '.error_box with error_geographic_item returns a shape' do
        # case 2a - error geo_item
        @e_g_i.save
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_geographic_item: @e_g_i)
        expect(georeference.save).to be_true
        expect(georeference.error_box?.geo_object.to_s).to eq(BOX_1.to_s)
      end

      specify 'error_radius, when provided, should contain geographic_item' do
        # case 2c
        # pending 'implementation of geo_object for geographic_area'
        # since the point specified is the center of a circle (or bounding box) defined by the error_radius, that point
        # must ALWAYS be 'contained' within the radius
        georeference = Georeference::VerbatimData.new(collecting_event: @c_e,
                                                      error_radius:     16000)
        expect(georeference.save).to be_true
        expect(georeference.error_box?.contains?(georeference.geographic_item.geo_object)).to be_true
      end

      specify 'error_radius, when provided, should contain error_geographic_item, when provided' do
        # case 3
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_geographic_item: @e_g_i,
                                                      error_radius:          160000)
        georeference.save
        expect(georeference).to be_true
        expect(georeference.error_geographic_item.contains?(georeference.geographic_item)).to be_true
        expect(georeference.error_geographic_item.contains?(georeference.geographic_item)).to be_true
        # in this case, error_box returns bounding box of error_radius, and should contain the error_geographic_item
        expect(georeference.error_box?.contains?(georeference.error_geographic_item.geo_object)).to be_true
      end

      specify 'collecting_event.geographic_area.geo_object contains self.geographic_item.geo_object or larger than georeference ?!' do
        # TODO: Don't know what 'or larger than georeference ?!' is supposed to mean
        #pending 'determination of what \'something like this\' means in the context of collecting_event'
        #   Need a GeographicArea somewhere on earth called
        # need a collecting event using box_1
        georeference = Georeference::VerbatimData.new(collecting_event: @c_e)
        expect(georeference.save).to be_true

        # @c_e got saved...
        expect(@c_e.new_record?).to be_false
        #
        # TODO: follow the save propagation chain and figure out why @c_e.@g_a.@area_d DID NOT get saved
        expect(@c_e.geographic_area.default_geographic_item.new_record?).to be_true
        # force the save
        expect(@c_e.geographic_area.default_geographic_item.save).to be_true

        expect(georeference.collecting_event.geographic_area.geo_object.contains?(georeference.geographic_item.geo_object)).to be_true

      end
    end
  end


  context 'associations' do
    context 'belongs_to' do

      # Build a valid_georeference

      specify 'geographic_item' do
        expect(valid_georeference_geo_locate).to respond_to :geographic_item
        expect(valid_georeference_geo_locate.geographic_item.class).to eq(GeographicItem)
      end

      specify 'error_geographic_item' do
        expect(valid_georeference_geo_locate).to respond_to :error_geographic_item
      end

      specify 'collecting_event' do
        expect(valid_georeference_geo_locate).to respond_to :collecting_event
      end
    end

  end

  context 'scopes' do

    before(:each) {
      # build some geo-references for testing using existing factories and geometries, something roughly like this 
      @gr1 = FactoryGirl.build(:valid_georeference,
                               collecting_event: FactoryGirl.build(:valid_collecting_event, verbatim_locality: 'Some string'),
                               geographic_item:  FactoryGirl.build(:geographic_item_with_polygon)) # swap out the polygon with another shape if needed

      # ...
      # @gr2
      # @gr3 
    }

    specify '.within_radius_of(geographic_item, distance)' do
      pending 'determinization of what is intended'
      # Return all Georeferences within some distance of a geographic_item
      # You're just going to use existing scopes in geographic item here, something like:
      # .where{geographic_item_id in GeographicItem.within_radius_of('polygon', geographic_item, distance)}
    end

    specify '.where_in_error_range_of(geographic_item, distance)' do
      pending 'adding #within_error_range of to georeference'
      # same as prior, but
      # .where{geographic_item_error_id: ... } 
    end

    specify '.with_locality_like(String)' do
      pending 'determinization of what is intended'
      # return all Georeferences that are attached to a CollectingEvent that has a verbatim_locality that includes String somewhere
      # Joins collecting_event.rb and matches %String% against verbatim_locality 

      # .where(id in CollectingEvent.where{verbatim_locality like "%var%"})
    end

    specify '.with_locality(String)' do
      pending 'determinization of what is intended'
      # return all Georeferences that are attached to a CollectingEvent that has a verbatim_locality = String
      # Joins collecting_event.rb and matches String against verbatim_locality,
      # .where(id in CollectingEvent.where{verbatim_locality = "var"})
    end

    specify '.with_geographic_area(geographic_area)' do
      pending 'determinization of what is intended'
      # where{geograhic_item_id: geographic_area.id}
    end
  end

  context 'request responses' do
    specify 'creates a geo_object' do
      #pending 'fixup on \'c\' vs. \'georeference\''
      c = Georeference::GeoLocate.new(request:          request_params,
                                      collecting_event: FactoryGirl.build(:valid_collecting_event))
      c.locate
      c.save

      expect(c.geographic_item.class).to eq(GeographicItem)
      expect(c.geographic_item.geo_object.class).to eq(RGeo::Geographic::ProjectedPointImpl)
    end
=begin
      georeference.locate
      georeference.save!
      expect(georeference.geographic_item.class).to eq(GeographicItem)
      expect(georeference.geographic_item.geo_object.class).to eq(RGeo::Geographic::ProjectedPointImpl)
    end
=end

    specify 'can be geometrically compared through #geographic_item.geo_object' do
      c_locator = Georeference::GeoLocate.new(request:          request_params,
                                              collecting_event: FactoryGirl.build(:valid_collecting_event))
      c_locator.locate
      u_locator = Georeference::GeoLocate.new(request:          {country: 'USA', locality: 'Urbana', state: 'IL', doPoly: 'true'},
                                              collecting_event: FactoryGirl.build(:valid_collecting_event))

      c_locator.save
      u_locator.save

      expect(c_locator.error_geographic_item.geo_object.intersects?(u_locator.error_geographic_item.geo_object)).to be_true
      expect(c_locator.geographic_item.geo_object.distance(u_locator.geographic_item.geo_object)).to eq 0.03657760243645799
      expect(c_locator.geographic_item.geo_object.distance(u_locator.error_geographic_item.geo_object)).to eq 0.014470082533135583
      expect(u_locator.geographic_item.geo_object.distance(c_locator.error_geographic_item.geo_object)).to eq 0.021583346308561287
    end
  end


  context 'methods provide that' do
    context 'the object returns a type' do
      specify 'which is GeoLocate' do

        geo_locate = Georeference::GeoLocate.new(request:          {country: 'USA', locality: 'Urbana', state: 'IL', doPoly: 'true'},
                                                 collecting_event: FactoryGirl.build(:valid_collecting_event))
        geo_locate.build
        geo_locate.save

        expect(geo_locate.type).to eq 'Georeference::GeoLocate'
      end

      specify 'which is Verbatim' do
        georeference = Georeference::VerbatimData.new(collecting_event: FactoryGirl.build(:valid_collecting_event,
                                                                                          minimum_elevation:  795,
                                                                                          verbatim_latitude:  '40.092067',
                                                                                          verbatim_longitude: '-88.249519'))
        #georeference = FactoryGirl.build(:valid_georeference_verbatim_data)
        expect(georeference.type).to eq 'Georeference::VerbatimData'
      end
    end

  end
end


