require 'normalizr/normalizr'
require 'normalizr/schema'
require 'normalizr/array_of'

describe Normalizr, '.normalize!' do

  Schema = Normalizr::Schema
  ArrayOf = Normalizr::ArrayOf

  # Prepare schema
  let(:comment) {
    Schema.new('comments')
  }
  let(:author) {
    Schema.new('authors')
  }
  let(:post) {
    Schema.new('posts', {
      author: author,
      comments: ArrayOf.new(comment)
    })
  }


  context 'with ids' do

    it 'normalizes' do
      obj = {
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
            title: 'post 2',
            author: { id: 55, name: 'doe' }
          }
        ],
      }

      actual = Normalizr.normalize!(obj, { posts: ArrayOf.new(post) })
      expected = {
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
        }
      }
      expect(actual).to eq expected
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
