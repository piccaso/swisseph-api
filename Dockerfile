FROM ubuntu:bionic as base

FROM base as swephbuild
RUN apt-get update && apt-get -y install git build-essential 
RUN mkdir -p /src/swisseph
RUN git clone --depth 1 --branch master https://github.com/aloistr/swisseph /src/swisseph
WORKDIR /src/swisseph
RUN make swetest
RUN apt-get -y install p7zip-full
COPY ephe /src/ephe
WORKDIR /src/ephe2
RUN 7z x /src/ephe/ephe.7z.001 -o/src/ephe2


FROM golang:jessie AS apibuild
ADD api.go .
RUN go build -v -o /api api.go

FROM base
WORKDIR /opt/sweapi
COPY --from=swephbuild /src/swisseph/swetest /bin/swetest
COPY --from=swephbuild /src/swisseph/ephe /users/ephe
COPY --from=swephbuild /src/ephe2 /users/ephe2
COPY --from=apibuild /api /bin/sweapi
COPY static /opt/sweapi/static
