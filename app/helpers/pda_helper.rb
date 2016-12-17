module PdaHelper

  class PDA < NfaHelper::NFA
    attr_accessor :stack_user

    def initialize(params={})
      super(params)
      @alphabet << '&' unless !@alphabet || @alphabet.include?('&')
      @stack = []
      @stack_user = params['stack_user']
		end

    def accepts?(input)
      resp = consume(input)
      resp[:accept]
    end

    #Metodo transiciones
    def transition()
    end


  end
end
