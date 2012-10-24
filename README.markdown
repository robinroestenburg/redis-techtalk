## Redis, Finalist NoSQL techtalks

This repo is part of a techtalk I gave on Redis. 

You can find the following things in here:

* `/presentation`: holds a pdf version of the presentation
* `/create-bulk-data`: a little program to create import data (generates a file
  containing permutations)
* `/import-bulk-data`: several programs that import data in different ways
  (normal, using pipelining and clustered)
* `/redis-configuration`: configurations for starting up Redis with different
  options.
* `/sinatra-twitter`: Twitter server written in Sinatra, see below.

### Twitter

For the hands-on part of this talk I have created a simple Twitter server. Users
can sign up and post tweets. Users can follow each other and statistics about
the number of followers and following are shown.

##### Assignment

I have removed the implementation from all methods interacting with Redis, and 
it is up to you to implement and get the whole system working again.

##### Running the server

In order to get the server running, perform the following commands:

```
cd sinatra-twitter
bundle
rackup
```

You should now have your own local Twitter running at `http://localhost:9292`.


