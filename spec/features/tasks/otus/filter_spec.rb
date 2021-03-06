require 'rails_helper'
require 'make_simple_world'

describe 'tasks/otus/filter', type: :feature, group: [:geo, :otus, :tn_authors] do

  context 'using simple_world' do
    let(:page_title) { 'Otus by area' }
    let(:index_path) { otus_filter_task_path }

    it_behaves_like 'a_login_required_and_project_selected_controller'

    context 'signed in as a user' do
      before {
        sign_in_user_and_select_project
        simple_world(@user.id, @project.id)
      }

      # need some people
      let(:sargon) { Person.where(first_name: 'of Akkad', last_name: 'Sargon').first }
      let(:andy) { Person.where(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author').first }
      let(:daryl) { Person.where(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon').first }
      let(:ted) { Person.where(last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC').first }
      let(:bill) { Person.where(first_name: 'Bill', last_name: 'Ardson').first }

      # need some otus
      let(:top_dog) { Otu.where(name: 'Top Dog').first }
      let(:nuther_dog) { Otu.where(name: 'Another Dog').first }
      let(:spooler) { Otu.where('name like ?', '%spooler%').first }
      let(:p4) { Otu.where(name: 'P4').first }
      let(:by_bill) { Otu.where('name like ?', '%by Bill%').first }
      let(:otu_a) { Otu.where(name: 'Otu_A').first }
      let(:abra) { Otu.where(name: 'Abra').first }
      let(:cadabra) { Otu.where('name like ?', '%cadabra%').first }
      let(:alakazam) { Otu.where('name like ?', '%alakazam%').first }

      # need some areas
      let(:area_a) { GeographicArea.where(name: 'A').first }
      let(:area_b) { GeographicArea.where(name: 'B').first }
      let(:area_e) { GeographicArea.where(name: 'E').first }
      let(:json_string) { '{"type":"Feature", "properties":{}, "geometry":{"type":"MultiPolygon", "coordinates":[[[[0, 10, 0], [10, 10, 0], [10, -10, 0], [0, -10, 0], [0, 10, 0]]]]}}' }

      # need some collection objects
      let(:co_a) {
        object = CollectingEvent.where(verbatim_label: 'Eh?').first
        object.collection_objects.first
      }

      let(:co_b) {
        object = CollectingEvent.where(verbatim_label: 'Bah').first
        object.collection_objects.first
      }

      describe '#set_area', js: true do #
        it 'renders count of otus in a specific names area' do
          visit(index_path)
          page.execute_script "$('#set_area')[0].scrollIntoView()"
          fill_area_picker_autocomplete('area_picker_autocomplete', with: 'A', select: area_a.id)
          click_button('Set area')
          expect(find('#area_count')).to have_text('6')
        end

        it 'renders count of otus in a specific names area' do
          visit(index_path)
          page.execute_script "$('#set_area')[0].scrollIntoView()"
          fill_area_picker_autocomplete('area_picker_autocomplete', with: 'B', select: area_b.id)
          click_button('Set area')
          expect(find('#area_count')).to have_text('3')
        end

        it 'renders count of otus in a specific names area' do
          visit(index_path)
          page.execute_script "$('#set_area')[0].scrollIntoView()"
          fill_area_picker_autocomplete('area_picker_autocomplete', with: 'E', select: area_e.id)
          click_button('Set area')
          expect(find('#area_count')).to have_text('9')
        end

        it 'renders count of otus in a drawn area corresponding to b' do
          visit(index_path)
          find('#label_toggle_slide_area').click
          execute_script("document.getElementById('drawn_area_shape').type = 'text'")
          this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
          this_xpath.set area_b.to_simple_json_feature.to_s.gsub('=>', ":")
          click_button('Set area')
          expect(find('#area_count')).to have_text('3')
        end

        it 'renders count of otus in a drawn area' do
          visit(index_path)
          find('#label_toggle_slide_area').click
          execute_script("document.getElementById('drawn_area_shape').type = 'text'")
          this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
          this_xpath.set json_string
          click_button('Set area')
          expect(find('#area_count')).to have_text('9')
        end
      end

      describe '#set_nomen', js: true do
        it 'renders count of otus from a specific name without descendants' do
          visit(index_path)
          page.execute_script "$('#set_nomen')[0].scrollIntoView()"
          fill_autocomplete('nomen_id_for_by_nomen', with: 'bee', select: co_b.taxon_names.last.id)
          click_button('Set Nomenclature')
          expect(find('#nomen_count')).to have_text('1') # 'beevitis'
        end

        it 'renders count of otus from a taxon name of its own rank with descendants' do
          visit(index_path)
          page.execute_script "$('#set_nomen')[0].scrollIntoView()"
          find('#descendants').click
          fill_autocomplete('nomen_id_for_by_nomen', with: 'topdog', select: top_dog.taxon_name.id)
          wait_for_ajax
          find('#rank_class').select('family (ICZN)')
          wait_for_ajax
          click_button('Set Nomenclature')
          expect(find('#nomen_count')).to have_text('2') # Top Dog, Top dog by Bill
        end

        it 'renders count of otus from a specific name with descendants without rank specified' do
          visit(index_path)
          page.execute_script "$('#set_nomen')[0].scrollIntoView()"
          find('#descendants').click
          fill_autocomplete('nomen_id_for_by_nomen', with: 'Topdog', select: top_dog.taxon_name.id)
          click_button('Set Nomenclature')
          expect(find('#nomen_count')).to have_text('6') # Top Dog, Top dog by Bill, Abra, Abra cadabra, Abra cadabra alakazam, Sargon's spooler
        end

        it 'renders count of otus from a specific name with descendants with specific rank' do
          visit(index_path)
          page.execute_script "$('#set_nomen')[0].scrollIntoView()"
          find('#descendants').click
          fill_autocomplete('nomen_id_for_by_nomen', with: 'Topdog', select: top_dog.taxon_name.id)
          find('#rank_class').select('species (ICZN)')
          click_button('Set Nomenclature')
          expect(find('#nomen_count')).to have_text('2') # Abra cadabra, Sargon's spooler
        end
      end

      describe '#set_author', js: true do

        it 'selects a taxon name author list (and)' do
          visit(index_path)
          page.execute_script "$('#set_author')[0].scrollIntoView()"
          find('#and_or_select__and_').click
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Sa', select_id: sargon.id, object_type: 'author')
          wait_for_ajax
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Pe', select_id: daryl.id, object_type: 'author')
          wait_for_ajax
          click_button('Set Author')
          wait_for_ajax
          expect(find('#author_count')).to have_text('1') # Sargon's spooler
        end

        it 'selects a taxon name author list (or)' do
          visit(index_path)
          page.execute_script "$('#set_author')[0].scrollIntoView()"
          find('#and_or_select__or_').click
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Sa', select_id: sargon.id, object_type: 'author')
          wait_for_ajax
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Bi', select_id: bill.id, object_type: 'author')
          wait_for_ajax
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Te', select_id: ted.id, object_type: 'author')
          wait_for_ajax
          click_button('Set Author')
          wait_for_ajax
          expect(find('#author_count')).to have_text('7') # Sargon's spooler
        end
      end

      describe '#find', js: true do
        before {
          t_n_id = Protonym.where(name: 'beevitis').first.id
          visit(index_path)
          fill_area_picker_autocomplete('area_picker_autocomplete', with: 'E', select: area_e.id)
          click_button('Set area')
          wait_for_ajax

          page.execute_script "$('#set_nomen')[0].scrollIntoView()"
          fill_autocomplete('nomen_id_for_by_nomen', with: 'bee', select: t_n_id)
          click_button('Set Nomenclature')

          find('#find_area_and_nomen_commit').click
          wait_for_ajax
        }

        it 'renders count of objects and table found using a drawn area and date range' do
          find('#paging_data', visible: true, text: 'Displaying 1 otu')
          expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Taxon name')
          find('.filter-button').click()
          find('#find_area_and_nomen_commit').click
          wait_for_ajax
          find('#paging_data', visible: true, text: 'Displaying 1 otu')
          expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Taxon name')
        end
      end

      describe '#find none', js: true do
        before {
          t_n_id = Protonym.where(name: 'beevitis').first.id
          visit(index_path)
          fill_area_picker_autocomplete('area_picker_autocomplete', with: 'A', select: area_a.id)
          click_button('Set area')
          wait_for_ajax

          page.execute_script "$('#set_nomen')[0].scrollIntoView()"
          fill_autocomplete('nomen_id_for_by_nomen', with: 'bee', select: t_n_id)
          click_button('Set Nomenclature')

          find('#find_area_and_nomen_commit').click
          wait_for_ajax
        }

        it 'renders count of objects and table found using name' do
          find('#paging_data', visible: true, text: 'Displaying no otus')
          expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Taxon name')
        end
      end

    end
  end
end
