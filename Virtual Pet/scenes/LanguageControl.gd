extends Label


export var language_folder = 'user://language_data/';
var links = {};
var sentence_lengths = [];


func _ready():
	self.load_language_module();


func _process(delta):
	if Input.is_action_just_released("left_click"):
		self.generate_sentence_test();


func load_language_module():
	# So for this one we want to make a simple forest-based NLP model
	# As seen here: https://aclanthology.org/A00-2023.pdf
	# (There has to be an easier tutorial but I couldn't find it aymore,
	# and I'm confident enough now that I could replicate it myself)
	# 18:35
	
	# So basically, the logic:
	# 1. We take note of every word pair in a dataset
	# 2. Whenever we encounter an existing one we add the pair's score by one
	# 3. When we are asked to think of a new sentence, we randomly pick
	#    from the most likely sentence starters, and then the most likely
	#    word that follows, and so on.
	# 4. If we have time we can make it so the pet understands (vaguely) what
	#    we said and can learn from our dialogues, too.
	
	var f = File.new()
	f.open(language_folder+'test.txt', 1);  # READ
	# TODO: Change the line above to reading all files from a user:// directory
	var f_content = f.get_as_text();
	f.close();
	var lines = f_content.split('\n')
	for line in lines:
		var words_on_this_line = ['(SOF)'];  # "Start of Line"
		line = line.replace('.', ' .').replace(',', ' ,').replace('?', ' ?').replace('!', ' !')\
					.replace('…', ' …').replace('\r', '').replace('\n', '');
		line = line.to_lower();
		words_on_this_line.append_array(line.split(' '));
		words_on_this_line.append('(EOF)');
		sentence_lengths.append(words_on_this_line.size());
		for i in range(words_on_this_line.size()-1):
			var word_one = words_on_this_line[i];
			var word_two = words_on_this_line[i+1];
			if word_one in links.keys():
				if word_two in links[word_one].keys():
					links[word_one][word_two] += 1;
				else:
					links[word_one][word_two] = 1;
			else:
				links[word_one] = {word_two: 1};


func generate_sentence_test():
	var sentence = [];
	# Add first word
	sentence.append(choose_a_random_child(links['(SOF)']));
	while sentence[-1] != '(EOF)':
		sentence.append(choose_a_random_child(links[sentence[-1]]));
	sentence.pop_back();  # Remove EOF
	var sentence_joined = PoolStringArray(sentence).join(' ');
	sentence_joined = sentence_joined.replace(' .', '.').replace(' ,', ',').replace(' ?', '?').replace(' !', '!')\
					.replace(' …', '…');
	sentence_joined = capitalize_first(sentence_joined);
	self.text = sentence_joined;


func choose_a_random_child(dict_of_children):
	# Generate weighted list for random choice
	var weighted_list = [];
	for child in dict_of_children.keys():
		var weight = dict_of_children[child];
		weighted_list.append_array(array_of(child, weight));
	var choice = weighted_list[randi() % weighted_list.size()];
	return choice;


static func avg(l):
	var sum = 0;
	for i in l:
		sum += i;
	return sum / float(l.size());


static func array_of(values, num):
	return (str(values)+' ').repeat(num).rstrip(' ').split(' ');


static func capitalize_first(s: String):
	return s[0].to_upper() + s.substr(1);
