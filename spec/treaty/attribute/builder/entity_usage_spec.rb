# frozen_string_literal: true

RSpec.describe "use_entity method" do
  describe "Entity class validation" do
    it "accepts Treaty::Entity subclass" do
      entity_class = Class.new(Treaty::Entity) do
        string :name
      end

      treaty_class = Class.new(ApplicationTreaty) do
        version 1 do
          request do
            object :user do
              use_entity(entity_class)
            end
          end

          response 200 do
            object :user do
              string :id
            end
          end

          delegate_to ->(**) { {} }
        end
      end

      expect { treaty_class.info }.not_to raise_error
    end

    it "raises EntityUsage for regular class" do
      regular_class = Class.new do
        def self.name
          "NotAnEntity"
        end
      end

      expect do
        Class.new(ApplicationTreaty) do
          version 1 do
            request do
              object :user do
                use_entity(regular_class)
              end
            end

            response 200 do
              object :user do
                string :id
              end
            end

            delegate_to ->(**) { {} }
          end
        end
      end.to raise_error(Treaty::Exceptions::EntityUsage, /Expected a Treaty::Entity subclass/)
    end

    it "raises EntityUsage for symbol" do
      expect do
        Class.new(ApplicationTreaty) do
          version 1 do
            request do
              object :user do
                use_entity(:not_a_class)
              end
            end

            response 200 do
              object :user do
                string :id
              end
            end

            delegate_to ->(**) { {} }
          end
        end
      end.to raise_error(Treaty::Exceptions::EntityUsage, /Expected a Treaty::Entity subclass/)
    end
  end

  describe "attribute constraint" do
    it "raises EntityUsage when attributes defined after use_entity" do
      entity_class = Class.new(Treaty::Entity) do
        string :name
      end

      expect do
        Class.new(ApplicationTreaty) do
          version 1 do
            request do
              object :user do
                use_entity(entity_class)
                string :extra_field
              end
            end

            response 200 do
              object :user do
                string :id
              end
            end

            delegate_to ->(**) { {} }
          end
        end
      end.to raise_error(Treaty::Exceptions::EntityUsage, /Cannot define additional attributes/)
    end

    it "raises EntityUsage when use_entity called after attributes defined" do
      entity_class = Class.new(Treaty::Entity) do
        string :name
      end

      expect do
        Class.new(ApplicationTreaty) do
          version 1 do
            request do
              object :user do
                string :extra_field
                use_entity(entity_class)
              end
            end

            response 200 do
              object :user do
                string :id
              end
            end

            delegate_to ->(**) { {} }
          end
        end
      end.to raise_error(Treaty::Exceptions::EntityUsage, /use_entity must be called before/)
    end
  end

  describe "attribute copying" do
    it "copies entity attributes to request" do
      entity_class = Class.new(Treaty::Entity) do
        string :name
        string :email, format: :email
        integer :age, :optional
      end

      treaty_class = Class.new(ApplicationTreaty) do
        version 1 do
          request do
            object :user do
              use_entity(entity_class)
            end
          end

          response 200 do
            object :result do
              string :status
            end
          end

          delegate_to ->(**) { {} }
        end
      end

      info = treaty_class.info
      user_attrs = info.versions.first.dig(:request, :attributes, :user, :attributes)

      expect(user_attrs.keys).to contain_exactly(:name, :email, :age)
      expect(user_attrs[:name][:type]).to eq(:string)
      expect(user_attrs[:email][:options][:format]).to eq({ is: :email, message: nil })
      expect(user_attrs[:age][:options][:required][:is]).to be(false)
    end

    it "copies entity attributes to response" do
      entity_class = Class.new(Treaty::Entity) do
        string :id
        string :name
      end

      treaty_class = Class.new(ApplicationTreaty) do
        version 1 do
          request do
            object :data do
              string :input
            end
          end

          response 201 do
            object :user do
              use_entity(entity_class)
            end
          end

          delegate_to ->(**) { {} }
        end
      end

      info = treaty_class.info
      user_attrs = info.versions.first.dig(:response, :attributes, :user, :attributes)

      expect(user_attrs.keys).to contain_exactly(:id, :name)
    end

    it "works in array block" do
      entity_class = Class.new(Treaty::Entity) do
        string :provider
        string :handle
      end

      treaty_class = Class.new(ApplicationTreaty) do
        version 1 do
          request do
            array :socials do
              use_entity(entity_class)
            end
          end

          response 200 do
            object :result do
              string :status
            end
          end

          delegate_to ->(**) { {} }
        end
      end

      info = treaty_class.info
      socials_attrs = info.versions.first.dig(:request, :attributes, :socials, :attributes)

      expect(socials_attrs.keys).to contain_exactly(:provider, :handle)
    end
  end

  describe "nested entities" do
    it "copies deeply nested entity attributes" do
      social_entity = Class.new(Treaty::Entity) do
        string :provider
        string :value
      end

      author_entity = Class.new(Treaty::Entity) do
        string :name
        string :bio

        array :socials, :optional do
          use_entity(social_entity)
        end
      end

      treaty_class = Class.new(ApplicationTreaty) do
        version 1 do
          request do
            object :author do
              use_entity(author_entity)
            end
          end

          response 200 do
            object :result do
              string :status
            end
          end

          delegate_to ->(**) { {} }
        end
      end

      info = treaty_class.info
      author_attrs = info.versions.first.dig(:request, :attributes, :author, :attributes)

      expect(author_attrs.keys).to contain_exactly(:name, :bio, :socials)
      expect(author_attrs[:socials][:type]).to eq(:array)

      socials_attrs = author_attrs.dig(:socials, :attributes)
      expect(socials_attrs.keys).to contain_exactly(:provider, :value)
    end
  end

  describe "wrapper options" do
    it "applies options to wrapper, not entity contents" do
      entity_class = Class.new(Treaty::Entity) do
        string :name
        string :bio
      end

      treaty_class = Class.new(ApplicationTreaty) do
        version 1 do
          request do
            object :author, :optional do
              use_entity(entity_class)
            end
          end

          response 200 do
            object :result do
              string :status
            end
          end

          delegate_to ->(**) { {} }
        end
      end

      info = treaty_class.info
      author = info.versions.first.dig(:request, :attributes, :author)

      # The wrapper object should be optional
      expect(author[:options][:required][:is]).to be(false)

      # But the entity attributes should be required (Entity default)
      expect(author[:attributes][:name][:options][:required][:is]).to be(true)
      expect(author[:attributes][:bio][:options][:required][:is]).to be(true)
    end
  end

  describe "nesting level protection" do
    it "raises NestedAttributes when nesting level exceeded through deep entity chain" do
      # Create a chain of entities that exceeds the nesting limit (default: 5)
      # Level 1 entity
      level_5_entity = Class.new(Treaty::Entity) do
        string :value
      end

      level_4_entity = Class.new(Treaty::Entity) do
        object :level5 do
          use_entity(level_5_entity)
        end
      end

      level_3_entity = Class.new(Treaty::Entity) do
        object :level4 do
          use_entity(level_4_entity)
        end
      end

      level_2_entity = Class.new(Treaty::Entity) do
        object :level3 do
          use_entity(level_3_entity)
        end
      end

      level_1_entity = Class.new(Treaty::Entity) do
        object :level2 do
          use_entity(level_2_entity)
        end
      end

      # This should exceed the default nesting level of 5
      expect do
        Class.new(Treaty::Entity) do
          object :level1 do
            use_entity(level_1_entity)
          end
        end
      end.to raise_error(Treaty::Exceptions::NestedAttributes, /Nesting level.*exceeds maximum/)
    end

    it "allows nesting within the limit" do
      # Create a chain within the nesting limit
      level_3_entity = Class.new(Treaty::Entity) do
        string :value
      end

      level_2_entity = Class.new(Treaty::Entity) do
        object :level3 do
          use_entity(level_3_entity)
        end
      end

      level_1_entity = Class.new(Treaty::Entity) do
        object :level2 do
          use_entity(level_2_entity)
        end
      end

      # This should work within the limit
      expect do
        Class.new(Treaty::Entity) do
          object :level1 do
            use_entity(level_1_entity)
          end
        end
      end.not_to raise_error
    end
  end

  describe "with existing DTOs" do
    it "works with Posts::AuthorDto and Posts::SocialDto" do
      # AuthorDto includes socials which uses SocialDto via use_entity
      info = Posts::AuthorDto.info

      expect(info.attributes[:name]).to be_present
      expect(info.attributes[:bio]).to be_present
      expect(info.attributes[:socials]).to be_present
      expect(info.attributes[:socials][:attributes]).to include(:provider, :handle)
    end
  end
end
