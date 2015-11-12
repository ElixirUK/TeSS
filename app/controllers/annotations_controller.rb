class AnnotationsController < Tate::AnnotationsController

  before_filter :authenticate_user!, except: [:index, :show]

end
