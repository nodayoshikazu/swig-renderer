PATH := ./node_modules/.bin:${PATH}

.PHONY : init clean-docs clean build test dist publish

init:
	npm install

docs:
	docco src/*.coffee

clean-docs:
	rm -rf docs/

clean: clean-docs
	rm -rf lib/ test/*.js

build:
	./node_modules/coffee-script/bin/coffee -o lib/ -c src/

test:
	node ./lib/index.js ./test/sample1.swig  < ./test/sample1.json
	node ./lib/index.js -f ./test/sample1.json ./test/sample1.swig
	node ./lib/index.js ./test/sample-fail.swig  < ./test/sample1.json
	node ./lib/index.js -f ./test/sample1.json ./test/sample-fail.swig
	node ./lib/index.js ./test/sample1.swig  < ./test/sample1-bad.json
	node ./lib/index.js -f ./test/sample1-bad.json ./test/sample1.swig

dist: clean init docs build test

publish: dist
	npm publish
