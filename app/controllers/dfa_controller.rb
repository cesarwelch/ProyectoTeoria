require 'json'

class DfaController < ApplicationController
	 def index
        @dfa = DfaHelper::DFA.new
    end
end
