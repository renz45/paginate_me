# Paginate Me 0.0.4

**Adam Rensel's Code**

Paginate me is a Ruby Gem that adds simple pagination functionality to views.



## Usage:
### Controller Code (users_controller.rb)

```ruby
class UsersController &lt; ApplicationController
	def index
		@title = "All Users"

	 paginate_me :users
	end
end
```

### View code (index.haml)
```haml
= paginate_for :users do |p|
  = p.link_to_first
	= p.link_to_next
	= p.page_out_of_total
	= p.link_to_previous
	= p.link_to_last
```
HTML output
```html
    <div class="paginate_me users"> 
      <a href="/users/page/10" class="first" title="first">First</a> 
              
      <a href="/users/page/10" class="next" title="next">Next</a> 
              
      <span>2 of 10</span> 
              
      <a href="/users/page/10" class="previous" title="previous">Previous</a> 
              
      <a href="/users/page/10" class="last" title="last">Last</a> 
    </div>
```
## Options for paginate_me(item, options ={})
* :url - The plugin builds it's base path from the item passed in according to standard rails routing resource format. A different base url can be passed in instead. /users/page/:page_number (/users is the base_url)
* :per_page - results per page, defaults to 10
* :params_var - variable set in routes that will hold the current page number ex: ` match "/users/page/:page", :to => "users#index" ` :page is the :params_var , defaults to :page


## Options for paginate_for(item, options = {}, &block)
* :class - add classes to div container tag
* :slug - slug used for url, defaults to 'page', the controller will use the slug in the 'params' variable by default as well.


## Paginate Links
* link_to_first(options={}) - label for first button, goes to page 1 
* link_to_next(options={}) - label for next button, increments page by +1
* link_to_previous(options={}) - label for previous button subtracts pages by -1
* link_to_last(options={}) - goes to the last page available, based on total count
   **options**
    * :name - name of link
    * :class - classes for link pass an array for multiple classes
    * :title - title for link

## Information Output
* page_out_of_total - formats pagination info '1 of 10' standard rails 'content_tag' options apply

## Additional Information
* If multiple pagination is needed on one page, for example at the top and bottom of the list, the block of paginate links only needs to be passed to the first 'paginate_for' The additional 'paginate_for' will use the same block, or new blocks can be passed if a different look is required
* Make sure you add the correct routes to your routes.rb. For example if your passing in :users and are using a standard resource routing setup, you will need: ` match "/users/page/:page", :to => "users#index" `

