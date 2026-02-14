## systemd unit
`~/.config/systemd/user/kanata.service`
```
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Type=simple
ExecStart=%h/.nix-profile/bin/kanata --cfg %h/.config/kanata/config.kbd
Environment=DISPLAY=:0
Restart=no

[Install]
WantedBy=default.target
```


## udev rule permanente
`/etc/udev/rules.d/99-uinput.rules`
```
KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
```

## aggiungi utente al gruppo input
```sh
sudo usermod -aG input $USER
```

## attiva servizio
https://github.com/dreamsofcode-io/escapecontrol/blob/main/linux/kanata/README.md
```
systemctl --user daemon-reload
systemctl --user enable kanata.service
systemctl --user start kanata.service
systemctl --user status kanata.service   # check whether the service is running
```

## altre istruzioni se ancora non va
https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md

---

Altre cose


Perfect 🎉 — that’s exactly what we wanted to see!

```
crw-rw---- 1 root input 10, 223 /dev/uinput
```

✅ That means:

* The **udev rule is working** properly.
* `/dev/uinput` now belongs to group `input`.
* Any user in that group (like you) can read/write to it — so **Kanata can run without root**.

---

### 🧩 Next steps

1. **Make sure your user is in the `input` group:**

   ```bash
   groups $USER
   ```

   If you don’t see `input` listed, run:

   ```bash
   sudo usermod -aG input $USER
   ```

   Then log out and back in (or reboot) so the group membership takes effect.

2. **Restart Kanata:**

   ```bash
   systemctl --user restart kanata
   systemctl --user status kanata
   ```

   It should now show:

   ```
   Active: active (running)
   ```

---

### 💡 Optional: make it persistent

The udev rule will persist across reboots automatically.
However, if `/dev/uinput` is created before your rule loads on boot, it could still have root-only permissions until udev reprocesses it.

If that ever happens:

* You can add `uinput` to `/etc/modules-load.d/uinput.conf` to ensure it loads *after* udev is ready:

  ```bash
  echo uinput | sudo tee /etc/modules-load.d/uinput.conf
  ```

---

Now Kanata should start cleanly on every boot and you won’t need root anymore 🚀

Would you like me to show you how to make sure your `kanata.service` starts automatically and logs errors cleanly under your user?

