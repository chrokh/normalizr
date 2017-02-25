# normalizr

Like [normalizr.js] for Ruby hashes.

If you have JSON/YAML, then just parse the JSON/YAML into a hash and pass it in.



## Installation

```bash
gem install normalizr.rb
```


## Usage

```ruby
Normalizr.normalize!(hash, schema)
```

## Example

If we define the following schema...

```ruby
comment = Schema.new('comments')
author = Schema.new('authors')
post  = Schema.new('posts', {
  author: author,
  comments: ArrayOf.new(comment)
})
```


...and have the following nested hash...

```ruby
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
```


...and then pass the hash and the schema to normalizr...

```ruby
Normalizr.normalize!(obj, {
  posts: ArrayOf.new(post)
})
```


...then we get the following flat result, where collections are id-indexed hashes rather than plain arrays.

```ruby
{
  posts: {
    :11 => {
      id: 11,
      title: 'Relational normalization',
      author: 22,
      comments: [33]
    }
  },
  authors: {
    :22 => {
      id: 22,
      name: 'Darkwing Duck'
    }
  },
  comments: {
    :33 => {
      body: 'Interesting...'
    }
  }
}

```

**Remember**: If you want to say `Schema` (and so forth) rather than `Normalizr::Schema` you have to `include Normalizr`.



## Do you want new IDs?

If your hash does **not** have IDs, normalizr will generate them for you. If your hash **do** have IDs then normalizr will not overwrite them but assume you are using them appropriately. If your hash has IDs but you want to **generate new IDs anyway**, then invoke normalizr like this:

```ruby
Normalizr.normalize!(obj, schema, { new_keys: true })
```


## API Reference

TODO



[normalizr.js]: https://github.com/paularmstrong/normalizr
