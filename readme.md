# a live collaboration tool over a websocket #

- [CodeMirror](http://codemirror.net/) for all formating needs
- Websocket routing wrtten in Go using JSON to move information between clients
- HTML5 local storage to keep persistent settings

## about ##
A live code collaboration tool is handy to have around, more so when you find yourself posting code snippets...

- In order to use this effectively, you will need to run the binary on a visible network.
- For convenience, a built in webserver can handle the support files
- This is not hardened software, do not expect support outside of development.
- Requires friends to use.

## how to build ##
- [install go](http://golang.org/doc/install)
- fetch the source
- install websocket package
- build it

```
git clone https://github.com/dearing/collab.git
cd collab
go get
go build

Usage of collab.exe:
  -conf="collab.conf": JSON configuration
  -gen=false: generate default config

```
