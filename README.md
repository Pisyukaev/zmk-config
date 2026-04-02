# zmk-config

## Сборки

В `build.yaml` добавлена схема с USB-донглом на nRF52840:

- `mriya_left` — левая половинка как split-периферия;
- `mriya_right` — правая половинка как split-периферия;
- `nice_nano_v2 + zmk_dongle` — центральный донгл (USB + BLE) с поддержкой ZMK Studio;
- `nice_nano_v2 + settings_reset` — сервисная прошивка для сброса bonding/settings.

### Важно

Для донгла ZMK Studio включен без блокировки (`CONFIG_ZMK_STUDIO_LOCKING` не задан), чтобы не потерять доступ к настройке при отсутствии физических клавиш на донгле.
