require 'json'

class RegexController < ApplicationController

	def index

	end

	def compute
		hash = RegexHelper::FSM.convert_from_fsm(params['data'])
        hash = JSON.parse(hash) if hash.is_a?(String)
        states = hash['states']

	end

end
