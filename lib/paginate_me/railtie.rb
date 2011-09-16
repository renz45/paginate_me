require 'paginate_me/paginate'
module MyHelpers
  class Railtie < Rails::Railtie
    initializer "paginate_me.paginate" do
      ActionView::Base.send :include, PaginateMe::PMView
      ActionController::Base.send :include, PaginateMe::PMController
    end
  end
end