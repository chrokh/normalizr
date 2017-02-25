require 'normalizr/normalizr'
require 'normalizr/schema'
require 'normalizr/array_of'

describe Normalizr do

  Schema = Normalizr::Schema
  ArrayOf = Normalizr::ArrayOf

  # Prepare schema
  let(:post) {
    Schema.new('posts', {
      author: author,
      comments: ArrayOf.new(comment)
    })
  }
  let(:comment) { Schema.new('comments') }
  let(:author)  { Schema.new('authors') }
  let(:posts)   { ArrayOf.new(post) }
  let(:extra)   { Schema.new('extras') }
  let(:extras)  { ArrayOf.new(extra) }
  let(:schema) {
    {
      posts: posts,
    }
  }
  let(:schema_with_extras) {
    {
      posts: posts,
      extras: extras,
    }
  }

  context 'when key has no value' do
    let(:input) {
      {
        posts: []
      }
    }
    let(:expected) {
      {
        posts: {}
      }
    }

    xit 'replaces arrays with hashes' do
      actual = Normalizr.normalize!(input, { posts: ArrayOf.new(post) })
      expect(actual).to eq(expected)
    end
  end


  context 'with ids' do

    let(:denormalized) {
      {
        posts: [
          {
            id: 11,
            title: 'post 1',
            comments: [
              { id: 33, title: 'comment 1' },
              { id: 44, title: 'comment 2' },
            ],
            author: { id: 55, name: 'doe' }
          },
          {
            id: 22,
            comments: [],
            title: 'post 2',
            author: { id: 55, name: 'doe' }
          }
        ],
      }
    }

    let(:normalized) {
      {
        posts: {
          11 => {
            id: 11,
            title: 'post 1',
            comments: [33, 44],
            author: 55,
          },
          22 => {
            id: 22,
            title: 'post 2',
            comments: [],
            author: 55,
          },
        },
        comments: {
          33 => { id: 33, title: 'comment 1' },
          44 => { id: 44, title: 'comment 2' },
        },
        authors: {
          55 => { id: 55, name: 'doe' },
        },
      }
    }

    let(:denormalized_with_extras) { denormalized.merge(extras: []) }
    let(:normalized_with_extras)   { normalized.merge(extras: {}) }
    let(:broken_denormalized_with_extras) { denormalized.merge(extras: nil) }
    let(:broken_normalized_with_extras)   { normalized.merge(extras: nil) }
    let(:value_broken_denormalized_with_extras) { denormalized.merge(extras: :some_value) }
    let(:value_broken_normalized_with_extras)   { normalized.merge(extras: :some_value) }

    context '#normalize' do
      it 'handles hash' do
        actual = Normalizr.normalize!(denormalized, schema)
        expect(actual).to eq normalized
      end

      it 'handles schema' do
        actual = Normalizr.normalize!(denormalized[:posts], posts)
        expect(actual).to eq normalized
      end

      it 'handles empty collections' do
        actual = Normalizr.normalize!(denormalized_with_extras, schema_with_extras)
        expect(actual).to eq normalized_with_extras
      end

      it 'handles broken collections containing nil' do
        actual = Normalizr.normalize!(broken_denormalized_with_extras, schema_with_extras)
        expect(actual).to eq normalized_with_extras
      end

      it 'handles broken collections containing values' do
        actual = Normalizr.normalize!(value_broken_denormalized_with_extras, schema_with_extras)
        expect(actual).to eq value_broken_normalized_with_extras
      end


      context 'when asking for new ids' do
        it 'creates new ids but maintains relationships' do
          actual = Normalizr.normalize!(denormalized, schema, { new_keys: true })
          expect(actual[:posts].length).to eq 2
          expect(actual[:posts].keys).not_to eq([11, 22])
          expect(actual[:comments].keys).not_to eq([33, 44])
          expect(actual[:authors].keys).not_to eq([55])
        end

        it 'maintains relationships' do
          actual = Normalizr.normalize!(denormalized, schema, { new_keys: true })

          id = actual[:posts][actual[:posts].keys[0]][:comments][0]
          expect(actual[:comments][id][:title]).to eq 'comment 1'

          id = actual[:posts][actual[:posts].keys[0]][:comments][1]
          expect(actual[:comments][id][:title]).to eq 'comment 2'

          id = actual[:posts][actual[:posts].keys[0]][:author]
          expect(actual[:authors][id][:name]).to eq 'doe'
        end

        it 'does not mutate original hash' do
          original = denormalized.dup
          Normalizr.normalize!(denormalized, schema, { new_keys: true })
          expect(denormalized).to eq original
        end
      end
    end

    context '#denormalize, given hash' do
      it 'works' do
        actual = Normalizr.denormalize!(normalized, schema)
        expect(actual).to eq denormalized
      end

      it 'can pick specific entry' do
        actual = Normalizr.denormalize!(normalized, schema, 22)
        expect(actual[:posts]).to eq [denormalized[:posts][1]]
      end

      it 'can pick multiple specific entries' do
        actual = Normalizr.denormalize!(normalized, schema, [22])
        expect(actual[:posts]).to eq [denormalized[:posts][1]]
      end

      it 'handles empty collections' do
        actual = Normalizr.denormalize!(normalized_with_extras, schema_with_extras)
        expect(actual).to eq denormalized_with_extras
      end

      it 'handles broken collections containing nil' do
        actual = Normalizr.denormalize!(broken_normalized_with_extras, schema_with_extras)
        expect(actual).to eq denormalized_with_extras
      end

      it 'handles broken collections containing values' do
        actual = Normalizr.denormalize!(value_broken_normalized_with_extras, schema_with_extras)
        expect(actual).to eq value_broken_denormalized_with_extras
      end
    end

  end


  context 'without ids' do
    it 'normalizes and maintains references using generated ids' do
      obj = {
        posts: [
          {
            title: 'p0',
            comments: [
              { title: 'c00' },
              { title: 'c01' },
            ],
            author: { name: 'a0' }
          },
          {
            title: 'p1',
            author: { name: 'a1' }
          }
        ],
      }

      actual = Normalizr.normalize!(obj, { posts: ArrayOf.new(post) })

      # assert values
      expect(actual[:authors].values[0][:name]).to eq 'a0'
      expect(actual[:authors].values[1][:name]).to eq 'a1'
      expect(actual[:posts].values[0][:title]).to eq 'p0'
      expect(actual[:posts].values[1][:title]).to eq 'p1'
      expect(actual[:comments].values[0][:title]).to eq 'c00'
      expect(actual[:comments].values[1][:title]).to eq 'c01'

      # assert relationships
      expect(actual[:authors].keys[0]).to eq actual[:posts].values[0][:author]
      expect(actual[:authors].keys[1]).to eq actual[:posts].values[1][:author]
      expect(actual[:comments].keys[0]).to eq actual[:posts].values[0][:comments][0]
      expect(actual[:comments].keys[1]).to eq actual[:posts].values[0][:comments][1]
    end
  end
end

