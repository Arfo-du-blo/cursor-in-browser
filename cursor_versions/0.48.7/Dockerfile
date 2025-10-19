FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

LABEL maintainer="arfo_dublo@boards.digital" \
      org.opencontainers.image.authors="arfo_dublo@boards.digital" \
      org.opencontainers.image.source="https://github.com/Arfo-du-blo/cursor-in-browser/" \
      org.opencontainers.image.title="Cursor in browser" \
      org.opencontainers.image.description="Cursor container image allowing access via web browser"

# Set version, display and download link
ARG CURSOR_VERSION=0.48.7
ENV DISPLAY=:1
ENV CURSOR_DOWNLOAD_URL=https://downloads.cursor.com/production/66290080aae40d23364ba2371832bda0933a3641/linux/x64/Cursor-0.48.7-x86_64.AppImage

# Update and install necessary packages
RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl fuse python3.11-venv libfuse2 python3-xdg libgtk-3-0 libnotify4 libatspi2.0-0 libsecret-1-0 libnss3 desktop-file-utils fonts-noto-color-emoji git ssh-askpass && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Download Cursor AppImage and manage permissions
RUN curl --location --output Cursor.AppImage $CURSOR_DOWNLOAD_URL && \
    chmod a+x Cursor.AppImage


# Environment variables
ENV CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8443" \
    CUSTOM_USER="" \
    PASSWORD="" \
    SUBFOLDER="" \
    TITLE="Cursor v${CURSOR_VERSION}" \
    FM_HOME="/cursor"

# Add local files and Cursor icon
COPY root/ /
COPY cursor_icon.png /cursor_icon.png

# Expose ports and volumes
EXPOSE 8080 8443
VOLUME ["/config","/cursor"]
