require 'normalizr/normalizr'
require 'normalizr/schema'
require 'normalizr/array_of'

describe Normalizr, '.normalize!' do

  Schema = Normalizr::Schema
  ArrayOf = Normalizr::ArrayOf

  context do
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

      comment = Schema.new('comments')
      author = Schema.new('authors')
      post = Schema.new('posts', {
        author: author,
        comments: ArrayOf.new(comment)
      })

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
end
