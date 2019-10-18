require 'test_helper'

class GraphqlControllerTest < ActionDispatch::IntegrationTest

  def setup
    @models = [ Account,
      Document,
      Photo,
      Photo.const_get('HABTM_Properties'),
      Property,
      Property.const_get('HABTM_Photos'),
      Reference
    ]
  end

  # = Loading via Models =======================================================

  test 'entry points' do
    post '/graphql', params: { query: <<-GRAPHQL }
      {
        __schema {
          queryType {
            name
            fields { name }
          }
        }
      }
    GRAPHQL

    json = JSON(response.body)['data']
    fields = json.dig('__schema', 'queryType', 'fields')
    
    @models.map do |model|
      collection_name = model.graphql_field_name(true)
      collection_field = fields.find { |x| x['name'] == collection_name }

      singular_name = model.graphql_field_name
      singular_field = fields.find { |x| x['name'] == singular_name }

      assert_not_nil collection_field
      assert_not_nil singular_field
    end
  end

  test 'query data types' do
    post '/graphql', params: { query: <<-GRAPHQL }
      {
        __schema {
          queryType {
            fields {
              name
              args {
                name
                type { name }
              }
            }
          }
        }
      }
    GRAPHQL

    json = JSON(response.body)
    fields = json.dig('data', '__schema', 'queryType', 'fields')

    @models.each do |model|
      collection_name = model.graphql_field_name(true)
      field = fields.find { |x| x['name'] == collection_name }
      assert field
    end

    @models.each do |model|
      singular_name = model.graphql_field_name
      field = fields.find { |x| x['name'] == singular_name }

      assert field

      if model.primary_key
        assert field['args'].find { |x| x['name'] == model.primary_key }
      end
    end
  end

  test 'model data types' do
    post '/graphql', params: { query: <<-GRAPHQL }
      {
        __schema {
          types {
            name
            kind
            description
            fields {
              name
              type {
                name
                kind
                ofType {
                  name
                  kind
                  ofType {
                    name
                    kind
                    ofType {
                      name
                      kind
                    }
                  }
                }
              }
            }
          }
        }
      }
    GRAPHQL

    json = JSON(response.body).dig('data', '__schema', 'types')

    @models.each do |model|
      model_type = json.find { |x| x['name'] == model.graphql_name }
      assert_not_nil model_type

      model.columns.each do |column|
        column_type = model_type['fields'].find { |x| x['name'] == column.name.camelize(:lower) }

        assert_not_nil column_type

        if model.primary_key == column.name
          assert_equal "NON_NULL", column_type.dig('type', 'kind')
          assert_equal "ID", column_type.dig('type', 'ofType', 'name')
          assert_equal "SCALAR", column_type.dig('type', 'ofType', 'kind')
          next
        end

        expected_column_type = StandardAPI::Graphql::Types.column_graphql_type(model, column).to_s.demodulize
        if !column.null
          assert_equal "NON_NULL", column_type.dig('type', 'kind')
          assert_equal expected_column_type, column_type.dig('type', 'ofType', 'name')
        else
          assert_equal expected_column_type, column_type.dig('type', 'name')
        end
      end
    end

    # TODO: Test relations
    @models.each do |model|
      model_type = json.find { |x| x['name'] == model.graphql_name }

      associations = model.reflect_on_all_associations
      associations.each do |association|
        field_name = association.name.to_s.camelize(:lower)

        # Polymorphic associations are not currently supported.
        if association.polymorphic?
          assert_nil model_type['fields'].find { |x| x['name'] == field_name }
          next
        end

        association_type = model_type['fields'].find { |x| x['name'] == field_name }

        assert_equal field_name, association_type['name']
        case association.macro
        when :belongs_to
          column = if model.respond_to?(:left_model) # HABTM Gernrated Model
            model.columns.find { |x| x.name == model.left_model.name.foreign_key }
          else
            model.columns.find { |x| x.name == association.foreign_key }
          end

          if column.null
            assert_equal association.klass.to_s, association_type.dig('type', 'name')
          else
            assert_equal 'NON_NULL', association_type.dig('type', 'kind')
            assert_equal association.klass.to_s, association_type.dig('type', 'ofType', 'name')
            
          end
        when :has_many, :has_and_belongs_to_many
          assert_equal 'NON_NULL', association_type.dig('type', 'kind')
          assert_equal 'LIST', association_type.dig('type', 'ofType', 'kind')
          assert_equal 'NON_NULL', association_type.dig('type', 'ofType', 'ofType', 'kind')
          assert_equal association.klass.to_s, association_type.dig('type', 'ofType', 'ofType', 'ofType', 'name')
        when :has_one
          assert_equal association.klass.to_s, association_type.dig('type', 'name')
        end
      end
    end

  end

  # TODO: Test return if model.abstract_class?
  # TODO: Test namesapces models (eg. AH::Mistake AH::Action)

  # = Loading via Controller ===================================================

  # test 'entry points' do
  #   post '/graphql', params: { query: <<-GRAPHQL }
  #     {
  #       __schema {
  #         queryType {
  #           name
  #           fields { name }
  #         }
  #       }
  #     }
  #   GRAPHQL

  #   json = JSON(response.body)['data']

  #   model_names = @models.map do |model|
  #     model.model_name.plural
  #   end.sort

  #   assert_equal model_names, json.dig('__schema', 'queryType', 'fields').map { |x| x['name'] }.sort
  # end

  # test 'data types' do
  #   post '/graphql', params: { query: <<-GRAPHQL }
  #     {
  #       __schema {
  #         types {
  #           name
  #           kind
  #           description
  #           fields {
  #             name
  #             type {
  #               name
  #               kind
  #               ofType {
  #                 name
  #                 kind
  #               }
  #             }
  #           }
  #         }
  #       }
  #     }
  #   GRAPHQL

  #   json = JSON(response.body).dig('data', '__schema', 'types')

  #   @models.each do |model|
  #     model_type = json.find { |x| x['name'] == model.name }
  #     assert_not_nil model_type

  #     model.columns.each do |column|
  #       column_type = model_type['fields'].find { |x| x['name'] == column.name.camelize(:lower) }

  #       assert_not_nil column_type

  #       if model.primary_key == column.name
  #         assert_equal "NON_NULL", column_type.dig('type', 'kind')
  #         assert_equal "ID", column_type.dig('type', 'ofType', 'name')
  #         assert_equal "SCALAR", column_type.dig('type', 'ofType', 'kind')
  #         next
  #       end

  #       expected_column_type = StandardAPI::GraphQL::Types.column_graphql_type(model, column).to_s.demodulize
  #       if !column.null
  #         assert_equal "NON_NULL", column_type.dig('type', 'kind')
  #         assert_equal expected_column_type, column_type.dig('type', 'ofType', 'name')
  #       else
  #         assert_equal expected_column_type, column_type.dig('type', 'name')
  #       end
  #     end
  #   end

  #   # TODO: Test relations
  #   @models.each do |model|
  #     model_type = json.find { |x| x['name'] == model.name }
  #     puts model_type
  #     puts model_type['fields'].map { |x| x['name'] }.inspect
      
  #     associations = model.reflect_on_all_associations
  #     puts associations.map(&:name).inspect
  #     # byebug
  #   end

  # end

end