FROM public.ecr.aws/lts/ubuntu:latest as base

FROM base as swephbuild
RUN apt-get update && apt-get -y install git build-essential
RUN mkdir -p /src/swisseph
RUN git clone --depth 1 --branch master https://github.com/aloistr/swisseph /src/swisseph
WORKDIR /src/swisseph
RUN make swetest

FROM base
COPY --from=swephbuild /src/swisseph/swetest /bin/swetest
COPY --from=swephbuild /src/swisseph/ephe /users/ephe