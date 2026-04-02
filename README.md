# zmk-config

## Сборки

В `build.yaml` добавлена дополнительная сборка USB-донгла на nRF52840:

- `mriya_left` — основная прошивка левой половинки (как и раньше);
- `mriya_right` — прошивка правой половинки;
- `nice_nano_v2 + zmk_dongle` — прошивка донгла (USB + BLE) с поддержкой ZMK Studio;
- `nice_nano_v2 + settings_reset` — сервисная прошивка для сброса bonding/settings.

## ZMK Studio на донгле

Отдельный файл `config/nice_nano_v2_zmk_dongle.conf` включает параметры split central + USB/BLE + Studio RPC для донгла.
