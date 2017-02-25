require '../lib/'

obj = {
  posts: [
    {
      id: 11,
      title: 'Relational normalization',
      author: {
      id: 22,
      name: 'Darkwing Duck'
    },
    comments: {
      id: 33,
      body: 'Interesting...'
    }
    }
  ]
}

comment = Schema.new('comments')
author = Schema.new('authors')
post  = Schema.new('posts', {
    author: author,
      comments: ArrayOf.new(comment)
})


Normalizr.normalize!(obj, {
    posts: ArrayOf.new(post)
})
