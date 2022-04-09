# Home Assistant Add-on: Google Cloud DNS

Automatically update your Google Cloud DNS IP address with integrated HTTPS support via Let's Encrypt.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

This add-on will update DNS records that are hosted by [Google Cloud DNS][google-cloud-dns] to an IP of your choice. It includes support for Let’s Encrypt and automatically creates and renews your certificates. You need to have a domain zone hosted in Google Cloud DNS and request an API key in the Google Cloud Platform that has the ability to modify the zone before using this add-on.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[google-cloud-dns]: https://cloud.google.com/dns/
