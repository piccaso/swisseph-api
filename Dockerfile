FROM ubuntu:jammy as base

FROM base as swephbuild
RUN apt-get update && apt-get -y install git build-essential
RUN mkdir -p /src/swisseph
RUN git clone --depth 1 --branch master https://github.com/aloistr/swisseph /src/swisseph
WORKDIR /src/swisseph
RUN make swetest

FROM golang AS apibuild
ADD api.go .
RUN go build -v -o /api api.go

FROM base
WORKDIR /opt/sweapi
COPY --from=swephbuild /src/swisseph/swetest /bin/swetest
COPY --from=swephbuild /src/swisseph/ephe /users/ephe
COPY --from=apibuild /api /bin/sweapi
COPY static /opt/sweapi/static
