# whisper-ios
iOS application that provides a VPN via [Whisper](https://github.com/MercuryWorkshop/whisper), a [Wisp protocol](https://github.com/MercuryWorkshop/wisp-protocol) client that exposes the Wisp connection over a TUN device.

## Building `libwhisper.a`
1. Install the `aarch64-apple-ios` target.
2. Run `cargo b -r --target aarch64-apple-ios --lib` in the [Whisper](https://github.com/MercuryWorkshop/whisper) repo.
3. Built library will be at `target/aarch64-apple-ios/release/libwhisper.a`.
