# Paginate Me

**Adam Rensel's Code**

Paginate me is a Ruby Gem that adds simple pagination functionality to views.



## Usage
### Controller code (users_controller.rb)

```ruby
class UsersController &lt; ApplicationController
  def index
    @title = "All Users"

   paginate_me :users
  end
end
```

### View code (index.haml.html)

```haml
= paginate_for :users do |p|
  = p.link_to_first
  = p.link_to_next
  = p.page_out_of_total
  = p.link_to_previous
  = p.link_to_last
```
  
### HTML output

```html
<div class="paginate_me users"> 
  <a href="/users/page/10" class="first" title="first">First</a> 
  <a href="/users/page/10" class="next" title="next">Next</a> 
  <span>2 of 10</span> 
  <a href="/users/page/10" class="previous" title="previous">Previous</a> 
  <a href="/users/page/10" class="last" title="last">Last</a> 
</div>
```
### Options for paginate_me(item, options ={})

* :url - The plugin builds it's base path from the item passed in according to standard rails routing resource format. A different base url can be passed in instead. /users/page/:page_number (/users is the base_url)
* :per_page - results per page, defaults to 10

### Options for paginate_for(item, options = {}, &block)

* :class - add classes to div container tag
* :slug - slug used for url, defaults to 'page'

### Paginate Links

* link_to_first(options={}) - label for first button, goes to page 1 
* link_to_next(options={}) - label for next button, increments page by +1
* link_to_previous(options={}) - label for previous button subtracts pages by -1
* link_to_last(options={}) - goes to the last page available, based on total count
  * **options**
    * :name - name of link
    * :class - classes for link pass an array for multiple classes
    * :title - title for link

### Information Output
* page_out_of_total - formats pagination info '1 of 10' standard rails 'content_tag' options apply