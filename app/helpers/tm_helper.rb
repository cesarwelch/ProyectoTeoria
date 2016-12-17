module TmHelper
	class TM < Parent::Parent
		attr_accessor :inputAlphabet, :tapeAlphabet, :tape, :reject

		def initialize(elements={})
			yaml = {}
			yaml = YAML::load_file(elements[:file]) if elements.has_key? :file
			super(elements)
			@inputAlphabet = elements[:inputAlphabet] || yaml['inputAlphabet']
			@tapeAlphabet = elements[:tapeAlphabet] || yaml['tapeAlphabet']
			@tape = TMTape.new
			@accept = false
			@reject = false
		end

		def feed(input) 
			@tape = TMTape.new(input)
			@accept = false
			@reject = false
			movements = []
			stateHead = @start.to_s
			movements.push({state: stateHead, via: "-"})
			input.each_char do |symbol|
				toState = transition(stateHead, symbol)
				movements.push({state: toState, via: symbol})
				if @accept || @reject
					break
				else
					stateHead = toState
				end
			end
		      
			resp = {
				input: input,
				movements: movements,
				accept: @accept,
				reject: @reject,
				head: stateHead,
				tape: @tape.storage,
				output: @tape.output
			}
			resp
		end
end
