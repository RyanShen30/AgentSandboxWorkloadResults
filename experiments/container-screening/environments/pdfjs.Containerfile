FROM docker.io/library/node@sha256:0e5f906573693feaa1e21057ebdcfdb5bd5021f050b2dc7c9deceb629c7da2a8
WORKDIR /testbed
RUN git init /testbed && git -C /testbed remote add origin https://github.com/mozilla/pdf.js.git && git -c http.version=HTTP/1.1 -C /testbed fetch --depth 1 origin 484518614d75c1ac1f1a8db41c943774b5231de6 && git -C /testbed checkout --detach FETCH_HEAD
