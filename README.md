To use this Docker image, download the LM Studio AppImage for Linux into the local `app_image` directory and update the `LMSTUDIO_APPIMAGE` argument in the Dockerfile accordingly.

Additionally, you should mount a local directory to `/root/.lmstudio/models` in your `compose.yaml` to persist your models.
