# Debian 12
# https://github.com/docker-library/golang/blob/539882fb23e90d31854a51a773accf8731cf0c9d/1.22/bookworm/Dockerfile
FROM golang:1.22.5-bookworm

ARG user_name=developer
ARG user_id
ARG group_id
ARG dotfiles_repository="https://github.com/uraitakahito/dotfiles.git"

# Avoid warnings by switching to noninteractive for the build process
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    ca-certificates \
    git && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#
# Install packages
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    # Basic
    iputils-ping \
    # Editor
    vim emacs \
    # Utility
    tmux \
    # fzf needs PAGER(less or something)
    fzf \
    trash-cli && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#
# eza
# https://github.com/eza-community/eza/blob/main/INSTALL.md
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    gpg \
    wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /etc/apt/keyrings && \
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list && \
  chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list && \
  apt update && \
  apt install -y eza && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/
COPY zshrc-entrypoint-init.d /etc/zshrc-entrypoint-init.d

RUN git config --system --add safe.directory /app

#
# Add user and install basic tools.
#
RUN cd /usr/src && \
  git clone --depth 1 https://github.com/uraitakahito/features.git && \
  USERNAME=${user_name} \
  USERUID=${user_id} \
  USERGID=${group_id} \
  CONFIGUREZSHASDEFAULTSHELL=true \
    /usr/src/features/src/common-utils/install.sh
USER ${user_name}

#
# dotfiles
#
RUN cd /home/${user_name} && \
  git clone --depth 1 ${dotfiles_repository} && \
  dotfiles/install.sh

#
# delve
#
RUN go install github.com/go-delve/delve/cmd/dlv@latest

WORKDIR /app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["tail", "-F", "/dev/null"]
