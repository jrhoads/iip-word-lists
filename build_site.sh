#!/usr/bin/env bash

update=1;
exceptions=0;
use_existing=0;
text_path=iip_master_texts
xml_text_path=$text_path/epidoc-files;
#new_system=0;

run_script() {
	cd docs;
	exceptions_flag=""
	new_system_flag=""
	if [ $exceptions == 1 ]; then
		exceptions_flag="--fileexception"
	fi

	echo "Running Script...";
	../src/python/wordlist.py ../$xml_text_path/* --nodiplomatic --html_general\
	--plaintext --flat texts/plain $exceptions_flag $new_system_flag;
	#if [ $new_system == 1 ]; then
	#	new_system_flag="--new_system"
	#fi
	cd ..;
}
copy_static(){
	echo "Copying Static Assets...";
	cp src/web/wordlist.css docs/;
	cp src/web/style.css docs/;
	cp src/web/index_search.js docs/;
	cp src/web/doubletree.html docs/;
	cp -r src/web/doubletreejs docs/;
	cp src/web/levenshtein.min.js docs/;
	cp src/web/wordinfo.css docs/;
}

for word in $*; do 
	if [ "$word" == "--help" ] || [ "$word" == "-h" ]; then
		printf "Usage:\n
		-h, --help            Print this message.
		--no-update, -nu      Do not fetch epidoc files from github.
		--exceptions, -e      If an exception occurs in the python \
		code, print the error message.
		--use-existing, -ue   Do not rebuild the word lists.\n" |
		sed -e 's:\t::g';
		exit;
	elif [ "$word" == "--no-update" ] || [ "$word" == "-nu" ]; then
		update=0;
	elif [ "$word" == "--exceptions" ] || [ "$word" == "-e" ]; then
		exceptions=1;
	elif [ "$word" == "--new-system" ] || [ "$word" == "-ns" ]; then
		new_system=1;
	fi
	
done

reset_docs(){
	echo "Removing old site...";
	if [ -d docs ]; then
		rm -rf docs
	fi
	mkdir docs
}

process_doubletree(){
	echo "Processing doubletree-data...";
	cat docs/texts/plain/* > docs/combined.txt
	./src/python/per_line.py docs/combined.txt docs/doubletree-data.txt
}

if [ $update == 1 ]; then
	echo "Updating texts...";
	if [ -d $text_path ]; then
		cd $text_path;
		git pull;
		cd - > /dev/null;
	else
		git clone --depth=1 https://github.com/Brown-University-Library/iip-texts.git $text_path
	fi

	cd $xml_text_path;
	if [ -f interpretations.xml ]; then
		rm interpretations.xml;
	fi
	if [ -f include_publicationStmt.xml ]; then
		rm include_publicationStmt.xml;
	fi
	cd - > /dev/null;
fi

reset_docs;
copy_static;
run_script;
process_doubletree;

#cp src/web/wordlist.css docs/;
#cp src/web/style.css docs/;
#cp src/web/index_search.js docs/;
#cp src/web/doubletree.html docs/;
#cp -r src/web/doubletreejs docs/;
#cp src/web/levenshtein.min.js docs/;
#cp src/web/wordinfo.css docs/;

