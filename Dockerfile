ARG DEPENDENCIES_VERSION="latest"
FROM anarkiwi/gnuradio-dependencies:${DEPENDENCIES_VERSION} AS gr-builder

ARG MARCH=-march=native
ARG GNURADIO_TAG

WORKDIR /root
# includes rx_freq tag - https://github.com/gnuradio/gnuradio/commit/915601c4a5d994532815fbd5c75a3c34f1fbd320
RUN git clone --depth 1 https://github.com/gnuradio/gnuradio -b ${GNURADIO_TAG}
WORKDIR /root/gnuradio/build
RUN CMAKE_CXX_STANDARD=17 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} ${MARCH}" -DENABLE_DEFAULT=ON -DENABLE_PYTHON=ON -DENABLE_GNURADIO_RUNTIME=ON -DENABLE_GR_BLOCKS=ON -DENABLE_GR_FFT=ON -DENABLE_GR_FILTER=ON -DENABLE_GR_ANALOG=ON -DENABLE_GR_UHD=ON -DENABLE_GR_NETWORK=ON -DENABLE_GR_SOAPY=ON -DENABLE_GR_ZEROMQ=ON .. && make -j "$(nproc)" && make install

FROM anarkiwi/gnuradio-dependencies:${DEPENDENCIES_VERSION} AS driver-builder
COPY --from=gr-builder /usr/local /usr/local

FROM anarkiwi/gnuradio-dependencies:${DEPENDENCIES_VERSION}
COPY --from=driver-builder /usr/local /usr/local
RUN ldconfig -v
RUN python3 -c "from gnuradio import analog, blocks, gr, network, soapy, zeromq"
