
build:
	docker run -i -v `pwd`:/code nim:devel nim c -d:release mungehosts.nim

run-it:
	docker run -it -v `pwd`:/code nim:devel bash


