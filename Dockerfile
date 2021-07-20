

FROM archlinux:latest

# install dev dependencies
RUN pacman -Syu --noconfirm;
RUN pacman -Sy gcc --noconfirm;
RUN pacman -Sy clang --noconfirm;
RUN pacman -Sy make --noconfirm;
RUN pacman -Sy extra/cmake --noconfirm;
RUN pacman -Sy git --noconfirm;
RUN pacman -Sy base-devel --noconfirm;
RUN pacman -Sy extra/wget --noconfirm;
RUN pacman -Sy community/ninja  --noconfirm;

# install a recent build of boost
WORKDIR /software
# Just grabed most recent version of boost from the boost website
RUN wget https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.bz2
RUN tar --bzip2 -xf ./boost_1_76_0.tar.bz2
WORKDIR /software/boost_1_76_0
RUN ./bootstrap.sh
RUN ./b2
RUN ./b2 install 

WORKDIR /

# make a non root user
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN pacman -Sy sudo --noconfirm;

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # add sudo support
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
 

WORKDIR /

RUN sudo git clone --depth 1 --branch v2.0.4 https://github.com/arvidn/libtorrent 

WORKDIR /libtorrent

RUN git submodule update --init --recursive
WORKDIR /libtorrent/build

RUN BOOST_BUILD_PATH="/software/boost_1_76_0" cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 -G Ninja ..
RUN pwd;
RUN ninja;
RUN sudo ninja install;
WORKDIR /libtorrent/examples

# build examples
RUN BOOST_BUILD_PATH="/software/boost_1_76_0" /software/boost_1_76_0/b2

WORKDIR /libtorrent

RUN sudo chown -R $USERNAME:$USERNAME .

USER $USERNAME

 






