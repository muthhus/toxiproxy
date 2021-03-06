NAME=toxiproxy
VERSION=$(shell cat VERSION)
DEB=pkg/$(NAME)_$(VERSION)_amd64.deb
GODEP_PATH=$(shell pwd)/Godeps/_workspace
GOPATH=$(GODEP_PATH):$$GOPATH

.PHONY: packages deb test linux darwin

all: deb linux darwin
deb: $(DEB)
darwin: tmp/build/toxiproxy-darwin-amd64 
linux: tmp/build/toxiproxy-linux-amd64

build:
	GOPATH=$(GOPATH) go build -o toxiproxy

clean:
	rm tmp/build/*
	rm *.deb

test:
	GOPATH=$(GOPATH) go test

tmp/build/toxiproxy-linux-amd64:
	GOOS=linux GOARCH=amd64 GOPATH=$(GOPATH) go build -o $(@)

tmp/build/toxiproxy-darwin-amd64:
	GOOS=darwin GOARCH=amd64 GOPATH=$(GOPATH) go build -o $(@)

$(DEB): tmp/build/toxiproxy-linux-amd64
	fpm -t deb \
		-s dir \
		--name "toxiproxy" \
		--version $(VERSION) \
		--license MIT \
		--no-depends \
		--no-auto-depends \
		--architecture amd64 \
		--maintainer "Simon Eskildsen <simon.eskildsen@shopify.com>" \
		--description "TCP proxy to simulate network and system conditions" \
		--url "https://github.com/Shopify/toxiproxy" \
		$<=/usr/bin/toxiproxy \
		./share/toxiproxy.conf=/etc/init/toxiproxy.conf
