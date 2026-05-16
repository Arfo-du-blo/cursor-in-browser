FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

LABEL maintainer="arfo_dublo@boards.digital" \
      org.opencontainers.image.authors="arfo_dublo@boards.digital" \
      org.opencontainers.image.source="https://github.com/Arfo-du-blo/cursor-in-browser/" \
      org.opencontainers.image.title="Cursor in browser" \
      org.opencontainers.image.description="Cursor container image allowing access via web browser"

# Set display
ENV DISPLAY=:1

# Update and install necessary packages
RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl fuse python3.11-venv libfuse2 python3-xdg libgtk-3-0 libnotify4 libatspi2.0-0 libsecret-1-0 libnss3 desktop-file-utils fonts-noto-color-emoji git ssh-askpass yad && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Cursor API Download
# Download Cursor AppImage and manage permissions
RUN CURSOR_DOWNLOAD_URL=$(python3 -c "import urllib.request, json; response = urllib.request.urlopen('https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable'); data = json.load(response); print(data['downloadUrl'])") && \
    curl --location --output Cursor.AppImage "$CURSOR_DOWNLOAD_URL" && \
    chmod a+x Cursor.AppImage


# Environment variables
ENV CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8443" \
    CUSTOM_USER="" \
    PASSWORD="" \
    SUBFOLDER="" \
    TITLE="Cursor" \
    FM_HOME="/cursor"

# Add local files and Cursor icon
COPY root/ /
COPY cursor_icon.png /cursor_icon.png

# Normalize line endings and permissions on copied scripts
RUN find /defaults /etc/cont-init.d -type f -exec sed -i 's/\r$//' {} +

# When try to open a link, show a popup to the user with the link
RUN sed -i 's/\r$//' /usr/local/bin/xdg-open && \
    chmod +x /usr/local/bin/xdg-open

# Update Cursor script
RUN sed -i 's/\r$//' /usr/local/bin/update-cursor.sh && \
    chmod +x /usr/local/bin/update-cursor.sh

# Expose ports and volumes
EXPOSE 8080 8443
VOLUME ["/config","/cursor"]
