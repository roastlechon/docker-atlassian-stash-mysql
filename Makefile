

build:
	docker build -t="atlassian/stash" .

run: data
	docker run --volumes-from stash-data --name="stash" -d -p 7990:7990 -p 7999:7999 atlassian/stash

data:
	docker run -d -v /var/atlassian/application-data/stash --name="stash-data" atlassian/stash-data

.PHONY: build run data
