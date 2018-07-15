/*
 * Copyright (c) 2015 Tim Theede <pez2001@voyagerproject.de>
 *               2015 Terry Cain <terrys-home.co.uk>
 */

/*
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 */

#ifndef __HID_RAZER_KEYBOARD_CHROMA_H
#define __HID_RAZER_KEYBOARD_CHROMA_H

#include <IOKit/IOKitLib.h>
#include <IOKit/usb/IOUSBLib.h>

#ifndef USB_VENDOR_ID_RAZER
#define USB_VENDOR_ID_RAZER 0x1532
#endif

#ifndef USB_DEVICE_ID_RAZER_BLADE_STEALTH
#define USB_DEVICE_ID_RAZER_BLADE_STEALTH 0x0205
#endif

#ifndef USB_DEVICE_ID_RAZER_BLACKWIDOW_CHROMA_TE
#define USB_DEVICE_ID_RAZER_BLACKWIDOW_CHROMA_TE 0x0209
#endif

#ifndef USB_DEVICE_ID_RAZER_BLADE_QHD
#define USB_DEVICE_ID_RAZER_BLADE_QHD 0x020F
#endif

#ifndef USB_DEVICE_ID_RAZER_BLADE_PRO_LATE_2016
#define USB_DEVICE_ID_RAZER_BLADE_PRO_LATE_2016 0x0210
#endif

#ifndef USB_DEVICE_ID_RAZER_BLADE_STEALTH_LATE_2016
#define USB_DEVICE_ID_RAZER_BLADE_STEALTH_LATE_2016 0x0220
#endif

#ifndef USB_DEVICE_ID_RAZER_FIREFLY
#define USB_DEVICE_ID_RAZER_FIREFLY 0x0c00
#endif

#ifndef USB_DEVICE_ID_RAZER_MAMBA
#define USB_DEVICE_ID_RAZER_MAMBA 0x0045
#endif

#ifndef USB_DEVICE_ID_RAZER_HUNTSMAN
#define USB_DEVICE_ID_RAZER_HUNTSMAN 0x0226
#endif

#define RAZER_STEALTH_ROW_LEN 0x10
#define RAZER_STEALTH_ROWS_NUM 6

struct razer_kbd_device {
    IOUSBDeviceInterface **usbdev;
    unsigned int fn_on;
    char name[128];
    char phys[64];
    
    unsigned char block_keys[3];
    unsigned char left_alt_on;
};

int razer_attr_read_device_type(IOUSBDeviceInterface **usb_dev, char *buf);
int razer_attr_read_mode_game(IOUSBDeviceInterface **usb_dev, char *buf);
int razer_attr_write_mode_macro(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_mode_macro_effect(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_read_mode_macro_effect(IOUSBDeviceInterface **usb_dev, char *buf);
int razer_attr_write_mode_pulsate(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_read_mode_pulsate(IOUSBDeviceInterface **usb_dev, char *buf);
int razer_attr_read_tartarus_profile_led_red(IOUSBDeviceInterface **usb_dev, char *buf);
int razer_attr_read_tartarus_profile_led_green(IOUSBDeviceInterface **usb_dev, char *buf);
int razer_attr_read_tartarus_profile_led_blue(IOUSBDeviceInterface **usb_dev, char *buf);
int razer_attr_write_mode_none(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_mode_wave(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_mode_spectrum(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_mode_reactive(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_mode_static(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_mode_starlight(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_mode_breath(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_set_logo(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_mode_custom(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_set_fn_toggle(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_write_set_brightness(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
int razer_attr_read_set_brightness(IOUSBDeviceInterface **usb_dev, char *buf);
int razer_attr_write_matrix_custom_frame(IOUSBDeviceInterface **usb_dev, const char *buf, int count);
#endif
