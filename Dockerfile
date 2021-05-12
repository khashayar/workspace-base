FROM alpine:latest

RUN set -ex                                                         \
  && apk add --no-cache --update                                    \
    autoconf                                                        \
    automake                                                        \
    bash                                                            \
    build-base                                                      \
    ca-certificates                                                 \
    cmake                                                           \
    coreutils                                                       \
    curl                                                            \
    docker                                                          \
    docker-compose                                                  \
    gettext-tiny-dev                                                \
    git                                                             \
    less                                                            \
    libtool                                                         \
    lua                                                             \
    openssl                                                         \
    pkgconf                                                         \
    python3-dev                                                     \
    py3-pip                                                         \
    tmux                                                            \
    unzip                                                           \
    xclip                                                           \
    zsh

# build, install optimized nvim for better performance
RUN set -ex                                                         \
  && mkdir -p /usr/src                                              \
  && cd /usr/src                                                    \
  && git clone https://github.com/neovim/neovim.git                 \
  && cd neovim                                                      \
  && make CMAKE_BUILD_TYPE=RelWithDebInfo                           \
          CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local"     \
  && make install                                                   \
  && rm -r /usr/src/neovim

# build, install universal-ctags
RUN set -ex                                                         \
  && cd /usr/src                                                    \
  && git clone https://github.com/universal-ctags/ctags.git         \
  && cd /usr/src/ctags                                              \
  && ./autogen.sh                                                   \
  && ./configure                                                    \
  && make                                                           \
  && make install                                                   \
  && rm -rf /usr/src/ctags

ARG user=developer

ENV HOME /home/$user

RUN adduser --home $HOME                                            \
            --shell /bin/zsh                                        \
            --disabled-password                                     \
            $user

USER $user

WORKDIR $HOME

RUN mkdir -p $HOME/.SpaceVim.d

RUN set -ex && pip3 install --user pynvim

ADD init.toml $HOME/.SpaceVim.d/

# install OhMyZSH and SpaceVim
RUN curl -sLf https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
RUN curl -sLf https://spacevim.org/install.sh | bash

# install plugins and resolve VimProc start-up error
RUN nvim --headless +VimProcInstall                                 \
                    +'call dein#install()'                          \
                    +UpdateRemotePlugins                            \
                    +qall

CMD ["/bin/zsh"]

