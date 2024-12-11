FROM archlinux:latest
LABEL maintainer="taminob" email="dev@tb6.eu" version="1.0" type="archlinux"

# ensure system is up-to-date
RUN pacman -Sy --noconfirm archlinux-keyring && pacman -Scc --noconfirm
RUN pacman -Su --noconfirm && pacman -Scc --noconfirm
RUN pacman-db-upgrade

# install basic packages for config setup
RUN pacman -S --noconfirm sudo git zsh python python-pip neovim && pacman -Scc --noconfirm

RUN echo "root:root" | chpasswd
RUN useradd -m me
RUN echo "me:me" | chpasswd
RUN groupadd -r sudo
RUN usermod -aG sudo me
RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-sudo-group-nopasswd

USER me

RUN mkdir -p ~/sync/config

RUN git clone https://github.com/taminob/config ~/sync/config

# run the fix-path step from installation script; this should do nothing
RUN python ~/sync/config/install.py --noconfirm --configs --fix-path --host taminob-linux

# install configs
RUN python ~/sync/config/install.py --noconfirm --configs home .config --host taminob-linux
# install AUR helper
RUN python ~/sync/config/install.py --noconfirm --aur --host taminob-linux

# install packages
RUN python ~/sync/config/install.py --noconfirm --packages base --host taminob-linux && \
    sudo pacman -Scc --noconfirm
RUN python ~/sync/config/install.py --noconfirm --packages shell --host taminob-linux && \
    sudo pacman -Scc --noconfirm
RUN python ~/sync/config/install.py --noconfirm --packages dev --host taminob-linux && \
    sudo pacman -Scc --noconfirm
RUN python ~/sync/config/install.py --noconfirm --packages font --host taminob-linux && \
    sudo pacman -Scc --noconfirm
RUN python ~/sync/config/install.py --noconfirm --packages hacking --host taminob-linux && \
    sudo pacman -Scc --noconfirm

# setup and install neovim plugins
RUN nvim -c "PlugInstall" -c "qa" && \
    nvim -c "CocInstall -sync coc-markdownlint coc-json coc-sh coc-rust-analyzer coc-clangd coc-cmake coc-css coc-html coc-tsserver coc-pyright" -c "qa"

RUN sudo pkgfile --update

WORKDIR /home/me

CMD /bin/zsh
