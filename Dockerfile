FROM python:3.6.3-jessie
LABEL maintainer "jmc.leira@gmail.com"

# Install development tools.
RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  zsh \
  locales

# Install Vim dependencies
RUN apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
    python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git

RUN git clone https://github.com/vim/vim.git /tmp/vim && \
    cd /tmp/vim && ./configure --with-features=huge \
                               --enable-multibyte \
                               --enable-rubyinterp=yes \
                               --enable-pythoninterp=yes \
                               --enable-python3interp=yes \
                               --with-python3-config-dir=/usr/lib/python3.6/config \
                               --enable-perlinterp=yes \
                               --enable-luainterp=yes \
                               --enable-gui=gtk2 \
                               --enable-cscope \
                               --prefix=/usr/local && \
    make install && VIMRUNTIMEDIR=/usr/local/share/vim/vim80

# Configure locales.
ENV DEBIAN_FRONTEND noninteractive
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install virtualenv
RUN pip install virtualenv

# Creates a custom user to avoid using root.
# We do also force the 2000 UID to match the host
# user and avoid permissions problems.
# There are some issues about it:
# https://github.com/docker/docker/issues/2259
# https://github.com/nodejs/docker-node/issues/289
RUN  useradd -ms /bin/bash dev && \
  usermod -o -u 2000 dev

# Set the working dir
WORKDIR /home/dev

# Run from the dev user.
USER dev

# Install oh my zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

# Instal fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --bin

# Download custom preferences using dotfiles.
RUN git clone https://github.com/jcorral/dotfiles.git /home/dev/dotfiles && \
  cd /home/dev/dotfiles &&  git submodule update --init --recursive

# Make the vim custom preferences, bash profile and custom scripts
# available for the dev user.
RUN ln -fs /home/dev/dotfiles/.zshrc /home/dev/.zshrc && \
    ln -fs /home/dev/dotfiles/.vim /home/dev/.vim && \
    ln -fs /home/dev/dotfiles/.vimrc /home/dev/.vimrc

# Configure the .vim YouCompleteMe plugin.
RUN /home/dev/dotfiles/.vim/bundle/YouCompleteMe/install.py

ENTRYPOINT ["/bin/zsh"]
