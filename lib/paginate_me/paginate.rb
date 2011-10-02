module PaginateMe
  module PMController
    def paginate_me(item, options = {})

      #set generic param defaults
      @options = options
      @options[:params_var] ||= :page
      @options[:per_page] ||= 10
      @options[:current_page] = self.params[@options[:params_var]].to_i || 1
      @options[:order] ||= "created_at ESC"

      current_page = @options[:current_page]

      if item.is_a? String
        # a string can be passed in with the format below to customize pagination returns
        # posts/category_to_posts/category_id/2/tag_to_posts/tag_id/4,3,2
        # pagination item / optional table to join / colummn to join / value for where clause
        # the above string finds all posts with category id of 2 and tag id 4,3,2
        # category_to_posts is the association table containing post_id category_id

        # split the string into an array
        item_arr = item.split('/') # [posts,category_to_posts,category_id,2,tag_to_posts,tag_id,4]

        # the name of the model being paginated is assumed to be the first item, shift it out of the array
        model_name = item_arr.shift
        model = model_name.singularize.camelize.constantize

        # user the model name extracted from the string to call an assumed routing path method
        @options[:base_url] ||= method("#{model_name}_path").call
        
        tables_arr = []
        where_obj = {}
        col = ""
        count = 1

        # loop through the remaining items from the string and build an active record query structure
        # that allows for joins and where clauses
        item_arr.each do |a|
          case count
          when 1
            a.split(',').each do |tbl|
              tables_arr << tbl.to_sym
            end
          when 2
            col = a.to_sym unless a == "nil"
          when 3
            unless a == "nil"
              table_key = tables_arr[tables_arr.length - 1]
              obj = {}
              obj[col] = a.split(',')
              where_obj[table_key] = obj
            end
          end
          (count % 3 == 0 ? count = 1 : count += 1)
        end

        # insert the additional where object if present
        where_obj.merge @options[:where] unless @options[:where].nil?

        # do the query and set it to a class variable with the pagination item name
        instance_variable_set("@#{model_name}", 
          model.includes(tables_arr).where(where_obj).order(@options[:order]).limit(@options[:per_page]).offset((current_page-1) * @options[:per_page]) )
        
        #get the total page count of the items
        @options[:page_total] = ( model.includes(tables_arr).where(where_obj).count / @options[:per_page].to_f).ceil
        page_total = @options[:page_total]

      elsif item.is_a? Symbol

        model_name = item.to_s
        model = model_name.singularize.camelize.constantize

        @options[:base_url] ||= method("#{model_name}_path").call

        if @options[:where].nil?
          instance_variable_set("@#{model_name}", 
          model.order(@options[:order]).limit(@options[:per_page]).offset((current_page-1) * @options[:per_page]))
         
          @options[:page_total] = (model.count / @options[:per_page].to_f).ceil
        else

          instance_variable_set("@#{model_name}", 
          model.where(options[:where]).order(@options[:order]).limit(@options[:per_page]).offset((current_page-1) * @options[:per_page]))

          @options[:page_total] = (model.where(options[:where]).count / @options[:per_page].to_f).ceil
        end
        page_total = @options[:page_total]

        
      end
      # set bounds for the current page, this makes sure the current_page variable stays within
      # the max and min number of items
      if @options[:current_page] <= 0
        @options[:current_page] = 1
      elsif @options[:current_page] > page_total
        @options[:current_page] = page_total - 1
      end
    end
  end

  module PMView
    def paginate_for(item,options = {},&block)

      @page_block = block || @page_block
      raise ArgumentError, "Missing Block" if @page_block.nil?

      model_name = item.to_s

      options = options.merge @options

      paginate_classes = options[:class] || model_name
      paginate_classes = paginate_classes.join " " if paginate_classes.is_a? Array

      paginate_builder = PaginateMeBuilder.new(options)

      content = capture(paginate_builder,&@page_block)

      content_tag(:div,content, :class => "paginate_me #{paginate_classes}")
    end
    
    class PaginateMeBuilder
      include ActionView::Helpers

      def initialize(options)

        @slug = options[:slug] ||= "page"
        @base_url = options[:base_url]
        @per_page = options[:per_page]
        @page_total = options[:page_total]
        @current_page = options[:current_page]

        @next_page = (@current_page >= @page_total ? @current_page : @current_page + 1).to_s
        @prev_page = (@current_page <= 1 ? @current_page : @current_page - 1).to_s   
      end

      def link_to_next(options = {})
        options[:name] ||= "Next"

        add_to_template paginate_link_to @next_page, options if @current_page < @page_total
      end

      def link_to_last(options = {})
        options[:name] ||= "Last"
        
        add_to_template paginate_link_to @page_total, options if @current_page < @page_total 
      end

      def link_to_previous(options = {})
        options[:name] ||= "Previous"

        add_to_template paginate_link_to @prev_page, options if @current_page > 1
      end

      def link_to_first(options = {})
        options[:name] ||= "First"

        add_to_template paginate_link_to 1, options if @current_page > 1
      end

      def page_out_of_total(options = {})
        content = "#{@current_page} of #{@page_total}"
        add_to_template content_tag(:span,content, options)
      end

      private 
        def paginate_link_to(page, args)
          name = args[:name]
          args[:class] ||= name.downcase
          args[:title] ||= name.downcase
          args.delete :name
          link_to(name, @base_url + "/#{@slug}/#{page}" , args)
        end

        def add_to_template(string)
          template = "\n\t" + string
          template.html_safe
        end
    end
  end
end

