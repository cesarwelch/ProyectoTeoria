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
end
