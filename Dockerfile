FROM alpine:latest

RUN set -ex && \
      apk add --no-cache --update \
        bash \
        build-base \
        ca-certificates \
        curl \
        docker \
        docker-compose \
        git \
        less \
        neovim \
        neovim-doc \
        openssh-client \
        python3-dev \
        py3-pip \
        tmux \
        zsh

# build, install universal-ctags
RUN set -ex && \
      apk add --no-cache --update --virtual build-deps autoconf automake && \
      git clone https://github.com/universal-ctags/ctags.git && \
      cd ctags && \
      ./autogen.sh && \
      ./configure && \
      make && make install && \
      cd ~ && rm -rf ctags && \
      apk del build-deps

RUN set -ex && pip3 install --user pynvim

# install OhMyZSH and SpaceVim
RUN curl -sLf https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
RUN curl -sLf https://spacevim.org/install.sh | bash

# fix VimProc start-up error
RUN nvim --headless +VimProcInstall +qa

ADD init.toml /root/.SpaceVim.d/

CMD ["/bin/zsh"]

