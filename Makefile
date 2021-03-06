# This Makefile was created by transforming the one for oct2py
# The line #------------------ shows where editing to date has been completed
# for the first attempt.
# Note: This is meant for vibration_toolbox developer use only

.PHONY: all clean test cover release gh-pages docs

# I don't know what the following line means/does
#export TEST_ARGS=--exe -v --with-doctest
export NAME=vibration_toolbox

export GHP_MSG="Generated gh-pages for `git log master -1 --pretty=short --abbrev-commit`"
export VERSION=`python -c "import $(NAME); print($(NAME).__version__)"`

#all: clean
#	python setup.py install

#----------------------------------------------------
clean:
	rm -rf build
	rm -rf dist
	find . -name "*.pyc" -o -name "*.py,cover"| xargs rm -f
#	killall -9 nosetests; true

test: clean
	python setup.py build
	export PYTHONWARNINGS="all"; cd build; nosetests $(TEST_ARGS) $(NAME)
	make clean

cover: clean
	pip install nose-cov
	nosetests $(TEST_ARGS) --with-cov --cov $(NAME) $(NAME)
	coverage annotate

release: clean
	pip install --user readme_renderer
	python setup.py check -r -s
	#python setup.py register
	rm -rf dist
	python setup.py sdist bdist_wheel
	# python setup.py sdist
	git tag v$(VERSION)
	git push origin --all
	git push origin --tags
	printf '\nUpgrade vibration toolbox with release and sha256 sum:'
	printf '\nOK, no sha256 sum yet:'
	twine upload dist/*
	shasum -a 256 dist/*.tar.gz

wheel: gh-pages
	rm -rf dist
	python setup.py sdist bdist_wheel

docs:
	# Warnings become errors and stop build
	export SPHINXOPTS=-W
	# pip install sphinx-bootstrap-theme numpydoc sphinx ghp-import
	# Run the make file in the docs directory
	make -C docs clean
	make -C docs html

html: docs

gh-pages:
	git checkout master
	git pull origin master
	git commit -a -m "Keep examples in sync"; true
	git push origin; true
	make docs
	ghp-import -n -p -m $(GHP_MSG) docs/_build/html
