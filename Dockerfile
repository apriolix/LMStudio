# FROM noneabove1182/lmstudio-cuda
# nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04
FROM nvidia/cuda@sha256:ef33852f3d321c9aedee5103f57b247114407d2e8382fe291a7ea5b2e6cb94ce AS base

# syntax=docker/dockerfile:1
# FROM ubuntu:22.04

# configurable variables
ARG LMSTUDIO_APPIMAGE=LM-Studio-0.3.30-2-x64.AppImage
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

WORKDIR /opt/lmstudio

# base packages and FUSE for AppImage support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates wget curl xz-utils tar gzip \
      libfuse2 libgtk-3-0 libx11-6 libnss3 libasound2 \
      libxss1 libgconf-2-4 libglu1-mesa libxi6 \
      libpangocairo-1.0-0 libatk1.0-0 libxrender1 \
      libfontconfig1 libxtst6 procps && \
    rm -rf /var/lib/apt/lists/*

# copy AppImage from build context
COPY ./app_image/${LMSTUDIO_APPIMAGE} /opt/lmstudio/${LMSTUDIO_APPIMAGE}

# make executable, try to extract; if extraction succeeds, move contents
RUN if [ -f "/opt/lmstudio/${LMSTUDIO_APPIMAGE}" ]; then \
      chmod +x /opt/lmstudio/${LMSTUDIO_APPIMAGE} && \
      /opt/lmstudio/${LMSTUDIO_APPIMAGE} --appimage-extract || true && \
      if [ -d /opt/lmstudio/squashfs-root ]; then \
        sh -c 'mv /opt/lmstudio/squashfs-root/* /opt/lmstudio/ 2>/dev/null || true' && \
        rm -rf /opt/lmstudio/squashfs-root && \
        rm -f /opt/lmstudio/${LMSTUDIO_APPIMAGE}; \
      fi \
    fi

# create symlink to expected startup command (if present)
RUN if [ -f /opt/lmstudio/AppRun ]; then chmod +x /opt/lmstudio/AppRun && ln -sf /opt/lmstudio/AppRun /usr/local/bin/lmstudio; \
    elif [ -f /opt/lmstudio/lmstudio ]; then chmod +x /opt/lmstudio/lmstudio && ln -sf /opt/lmstudio/lmstudio /usr/local/bin/lmstudio; fi

RUN apt update && apt install libgbm-dev -y
# RUN apt update && apt upgrade -y

# fix Chromium sandbox permissions
RUN if [ -f /opt/lmstudio/chrome-sandbox ]; then \
      chown root:root /opt/lmstudio/chrome-sandbox && \
      chmod 4755 /opt/lmstudio/chrome-sandbox; \
    fi

RUN apt-get update && \
    apt-get install -y --no-install-recommends xdg-utils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/lmstudio

# additional graphics and runtime libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglx0 \
    libglx-mesa0 \
    libgbm1 \
    libdrm2 \
    libxshmfence1 \
    libxrandr2 \
    libxcomposite1 \
    libxcursor1 \
    libxi6 \
    libxtst6 \
    libxdamage1 \
    xdg-utils \
    libgl1-mesa-dri \
    && rm -rf /var/lib/apt/lists/*
