/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Should you need to contact me, the author, you can do so by
 * e-mail - mail your message to Terry Cain <terry@terrys-home.co.uk>
 */

#include "razerkbd_driver.h"
#include "razerchromacommon.h"
#include "razercommon.h"

int razer_get_report(IOUSBDeviceInterface **usb_dev, struct razer_report *request_report, struct razer_report *response_report);
struct razer_report razer_send_payload(IOUSBDeviceInterface **dev, struct razer_report *request_report);

/**
 * Read device file "device_type"
 *
 * Returns friendly string of device type
 */
int razer_attr_read_device_type(IOUSBDeviceInterface **usb_dev, char *buf) {
    UInt16 product = -1;
    (*usb_dev)->GetDeviceProduct(usb_dev, &product);
    
    char *device_type = "";
    
    switch (product)
    {
        case USB_DEVICE_ID_RAZER_BLADE_STEALTH:
            device_type = "Razer Blade Stealth\n";
            break;
            
        case USB_DEVICE_ID_RAZER_BLADE_STEALTH_LATE_2016:
            device_type = "Razer Blade Stealth (Late 2016)\n";
            break;
            
        case USB_DEVICE_ID_RAZER_BLADE_QHD:
            device_type = "Razer Blade Stealth (QHD)\n";
            break;
            
        case USB_DEVICE_ID_RAZER_BLADE_PRO_LATE_2016:
            device_type = "Razer Blade Pro (Late 2016)\n";
            break;
            
        case USB_DEVICE_ID_RAZER_BLACKWIDOW_CHROMA_TE:
            device_type = "Razer BlackWidow Chroma Tournament Edition\n";
            break;
        default:
            device_type = "Unknown Device\n";
    }
    
    return sprintf(buf, device_type);
}

/**
 * Read device file "game_mode"
 *
 * Returns a string
 */
int razer_attr_read_mode_game(IOUSBDeviceInterface **usb_dev, char *buf) {
    struct razer_report report = razer_chroma_standard_get_led_state(VARSTORE, GAME_LED);
    struct razer_report response;
    
    response = razer_send_payload(usb_dev, &report);
    return sprintf(buf, "%d\n", response.arguments[2]);
}

/**
 * Write device file "mode_macro"
 *
 * When 1 is written (as a character, 0x31) Macro mode will be enabled, if 0 is written (0x30)
 * then game mode will be disabled
 */
int razer_attr_write_mode_macro(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    unsigned char enabled = (unsigned char)strtol(buf, NULL, 10);
    struct razer_report report = razer_chroma_standard_set_led_state(VARSTORE, MACRO_LED, enabled);
    
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Write device file "mode_macro_effect"
 *
 * When 1 is written the LED will blink, 0 will static
 */
int razer_attr_write_mode_macro_effect(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_report report;
    unsigned char enabled = (unsigned char)strtol(buf, NULL, 10);
    report = razer_chroma_standard_set_led_effect(VARSTORE, MACRO_LED, enabled);
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Read device file "macro_mode_effect"
 *
 * Returns a string
 */
int razer_attr_read_mode_macro_effect(IOUSBDeviceInterface **usb_dev, char *buf) {
    struct razer_report report = razer_chroma_standard_get_led_effect(VARSTORE, MACRO_LED);
    struct razer_report response = razer_send_payload(usb_dev, &report);
    
    return sprintf(buf, "%d\n", response.arguments[2]);
}

/**
 * Write device file "mode_pulsate"
 *
 * The brightness oscillates between fully on and fully off generating a pulsing effect
 */
int razer_attr_write_mode_pulsate(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_report report = razer_chroma_standard_set_led_effect(VARSTORE, BACKLIGHT_LED, 0x02);
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Read device file "mode_pulsate"
 *
 * Returns a string
 */
int razer_attr_read_mode_pulsate(IOUSBDeviceInterface **usb_dev, char *buf) {
    struct razer_report report = razer_chroma_standard_get_led_effect(VARSTORE, LOGO_LED);
    struct razer_report response = razer_send_payload(usb_dev, &report);
    
    return sprintf(buf, "%d\n", response.arguments[2]);
}

/**
 * Read device file "profile_led_red"
 *
 * Actually a Yellow LED
 *
 * Returns a string
 */
int razer_attr_read_tartarus_profile_led_red(IOUSBDeviceInterface **usb_dev, char *buf) {
    struct razer_report report = razer_chroma_standard_get_led_state(VARSTORE, RED_PROFILE_LED);
    struct razer_report response = razer_send_payload(usb_dev, &report);
    
    return sprintf(buf, "%d\n", response.arguments[2]);
}

/**
 * Read device file "profile_led_green"
 *
 * Returns a string
 */
int razer_attr_read_tartarus_profile_led_green(IOUSBDeviceInterface **usb_dev, char *buf) {
    struct razer_report report = razer_chroma_standard_get_led_state(VARSTORE, GREEN_PROFILE_LED);
    struct razer_report response = razer_send_payload(usb_dev, &report);
    
    return sprintf(buf, "%d\n", response.arguments[2]);
}

/**
 * Read device file "profile_led_blue"
 *
 * Returns a string
 */
int razer_attr_read_tartarus_profile_led_blue(IOUSBDeviceInterface **usb_dev, char *buf) {
    struct razer_report report = razer_chroma_standard_get_led_state(VARSTORE, BLUE_PROFILE_LED);
    struct razer_report response = razer_send_payload(usb_dev, &report);
    
    return sprintf(buf, "%d\n", response.arguments[2]);
}

/**
 * Write device file "mode_none"
 *
 * No keyboard effect is activated whenever this file is written to
 */
int razer_attr_write_mode_none(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_report report;
    razer_chroma_standard_matrix_effect_none(VARSTORE, BACKLIGHT_LED);
    
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Write device file "mode_wave"
 *
 * When 1 is written (as a character, 0x31) the wave effect is displayed moving left across the keyboard
 * if 2 is written (0x32) then the wave effect goes right
 *
 * For the extended its 0x00 and 0x01
 */
int razer_attr_write_mode_wave(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    unsigned char direction = (unsigned char)strtol(buf, NULL, 10);
    struct razer_report report;
    report = razer_chroma_standard_matrix_effect_wave(VARSTORE, BACKLIGHT_LED, direction);
    
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Write device file "mode_spectrum"
 *
 * Specrum effect mode is activated whenever the file is written to
 */
int razer_attr_write_mode_spectrum(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_report report;
    report = razer_chroma_standard_matrix_effect_spectrum(VARSTORE, BACKLIGHT_LED);
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Write device file "mode_reactive"
 *
 * Sets reactive mode when this file is written to. A speed byte and 3 RGB bytes should be written
 */
int razer_attr_write_mode_reactive(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_report report;
    
    if(count == 4) {
        unsigned char speed = (unsigned char)buf[0];
        report = razer_chroma_standard_matrix_effect_reactive(VARSTORE, BACKLIGHT_LED, speed, (struct razer_rgb*)&buf[1]);
        razer_send_payload(usb_dev, &report);
    } else {
        printf("razerkbd: Reactive only accepts Speed, RGB (4byte)");
    }
    
    return count;
}

/**
 * Write device file "mode_static"
 *
 * Set the keyboard to mode when 3 RGB bytes are written
 */
int razer_attr_write_mode_static(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_report report;
    
    if(count == 3) {
        report = razer_chroma_standard_matrix_effect_static(VARSTORE, BACKLIGHT_LED, (struct razer_rgb*)&buf[0]);
        razer_send_payload(usb_dev, &report);
    } else {
        printf("razerkbd: mode only accepts RGB (3byte)");
    }
    
    return count;
}

//static ssize_t razer_attr_write_set_key_row(IOUSBDeviceInterface **usb_dev, const char *buf, size_t count)
//{
//    struct razer_report report;
//    size_t offset = 0;
//    unsigned char row_id;
//    unsigned char start_col;
//    unsigned char stop_col;
//    unsigned char row_length;
//
//    //printk(KERN_ALERT "razerfirefly: Total count: %d\n", (unsigned char)count);
//
//    while(offset < count) {
//        if(offset + 3 > count) {
//            printf("razerfirefly: Wrong Amount of data provided: Should be ROW_ID, START_COL, STOP_COL, N_RGB\n");
//            break;
//        }
//
//        row_id = buf[offset++];
//        start_col = buf[offset++];
//        stop_col = buf[offset++];
//        row_length = ((stop_col+1) - start_col) * 3;
//
//        // printk(KERN_ALERT "razerfirefly: Row ID: %d, Start: %d, Stop: %d, row length: %d\n", row_id, start_col, stop_col, row_length);
//
//        if(row_id != 0) {
//            printf("razerfirefly: Row ID must be 0\n");
//            break;
//        }
//
//        if(start_col > stop_col) {
//            printf("razerfirefly: Start column is greater than end column\n");
//            break;
//        }
//
//        if(offset + row_length > count) {
//            printf("razerfirefly: Not enough RGB to fill row\n");
//            break;
//        }
//
//        report = razer_chroma_misc_one_row_set_custom_frame(start_col, stop_col, (unsigned char*)&buf[offset]);
//        razer_send_payload(usb_dev, &report);
//
//        // *3 as its 3 bytes per col (RGB)
//        offset += row_length;
//    }
//
//    return count;
//}

/**
* Write device file "mode_startlight"
*
* Starlight keyboard effect is activated whenever this file is written to (for bw2016)
*
* Or if an Ornata
* 7 bytes, speed, rgb, rgb
* 4 bytes, speed, rgb
* 1 byte, speed
*/
int razer_attr_write_mode_starlight(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_rgb rgb1 = {.r = 0x00, .g = 0xFF, .b = 0x00};
    struct razer_report report;
    report = razer_chroma_standard_matrix_effect_starlight_single(VARSTORE, BACKLIGHT_LED, 0x01, &rgb1);
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Write device file "mode_breath"
 */
int razer_attr_write_mode_breath(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_report report;

    switch(count) {
        case 3: // Single colour mode
            report = razer_chroma_standard_matrix_effect_breathing_single(VARSTORE, BACKLIGHT_LED, (struct razer_rgb*)&buf[0]);
            report.transaction_id.id = 0x1F;  // TODO move to a usb_device variable
            razer_send_payload(usb_dev, &report);
            break;
            
        case 6: // Dual colour mode
            report = razer_chroma_standard_matrix_effect_breathing_dual(VARSTORE, BACKLIGHT_LED, (struct razer_rgb*)&buf[0], (struct razer_rgb*)&buf[3]);
            report.transaction_id.id = 0x1F;  // TODO move to a usb_device variable
            razer_send_payload(usb_dev, &report);
            break;
            
        default: // "Random" colour mode
            report = razer_chroma_standard_matrix_effect_breathing_random(VARSTORE, BACKLIGHT_LED);
            report.transaction_id.id = 0x1F;  // TODO move to a usb_device variable
            razer_send_payload(usb_dev, &report);
            break;
            // TODO move default to case 1:. Then default: printk(warning). Also remove pointless buffer
    }

    return count;
}

/**
 * Write device file "set_logo"
 *
 * Sets the logo lighting state to the ASCII number written to this file.
 */
int razer_attr_write_set_logo(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    unsigned char state = (unsigned char)strtol(buf, NULL, 10);
    struct razer_report report = razer_chroma_standard_set_led_effect(VARSTORE, LOGO_LED, state);
    
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Write device file "mode_custom"
 *
 * Sets the keyboard to custom mode whenever the file is written to
 */
int razer_attr_write_mode_custom(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_report report;
    
    report = razer_chroma_standard_matrix_effect_custom_frame(VARSTORE); // Possibly could use VARSTORE
    razer_send_payload(usb_dev, &report);
    return count;
}

/**
 * Write device file "set_fn_toggle"
 *
 * Sets the logo lighting state to the ASCII number written to this file.
 */
int razer_attr_write_set_fn_toggle(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    unsigned char state = (unsigned char)strtol(buf, NULL, 10);
    struct razer_report report = razer_chroma_misc_fn_key_toggle(state);
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Write device file "set_brightness"
 *
 * Sets the brightness to the ASCII number written to this file.
 */
int razer_attr_write_set_brightness(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    unsigned char brightness = (unsigned char)strtol(buf, NULL, 10);
    struct razer_report report;
    
    
    report = razer_chroma_misc_set_blade_brightness(brightness);
    razer_send_payload(usb_dev, &report);
    
    return count;
}

/**
 * Read device file "macro_mode"
 *
 * Returns a string
 */
int razer_attr_read_set_brightness(IOUSBDeviceInterface **usb_dev, char *buf) {
    unsigned char brightness = 0;
    struct razer_report report;
    struct razer_report response;
    report = razer_chroma_misc_get_blade_brightness();
    
    response = razer_send_payload(usb_dev, &report);
    
    // Brightness is stored elsewhere for the stealth cmds
    brightness = response.arguments[1];
    
    return sprintf(buf, "%d\n", brightness);
}

/**
 * Write device file "matrix_custom_frame"
 *
 * Format
 * ROW_ID START_COL STOP_COL RGB...
 */
int razer_attr_write_matrix_custom_frame(IOUSBDeviceInterface **usb_dev, const char *buf, int count) {
    struct razer_report report;
    int offset = 0;
    unsigned char row_id;
    unsigned char start_col;
    unsigned char stop_col;
    unsigned char row_length;
    
    //printk(KERN_ALERT "razerkbd: Total count: %d\n", (unsigned char)count);
    
    while(offset < count)
    {
        if(offset + 3 > count)
        {
            printf("razerkbd: Wrong Amount of data provided: Should be ROW_ID, START_COL, STOP_COL, N_RGB\n");
            break;
        }
        
        row_id = buf[offset++];
        start_col = buf[offset++];
        stop_col = buf[offset++];
        row_length = ((stop_col+1) - start_col) * 3;
        
        // printk(KERN_ALERT "razerkbd: Row ID: %d, Start: %d, Stop: %d, row length: %d\n", row_id, start_col, stop_col, row_length);
        
        if(start_col > stop_col)
        {
            printf("razerkbd: Start column is greater than end column\n");
            break;
        }
        
        if(offset + row_length > count)
        {
            printf("razerkbd: Not enough RGB to fill row\n");
            break;
        }
        
        // Offset now at beginning of RGB data
        report.transaction_id.id = 0x80; // Fall into the 2016/blade/blade2016 to set device id
        razer_send_payload(usb_dev, &report);
        
        // *3 as its 3 bytes per col (RGB)
        offset += row_length;
    }
    
    
    return count;
}

/**
 * Send report to the keyboard
 */
int razer_get_report(IOUSBDeviceInterface **usb_dev, struct razer_report *request_report, struct razer_report *response_report) {
    return razer_get_usb_response(usb_dev, 0x02, request_report, 0x02, response_report);
}

/**
 * Function to send to device, get response, and actually check the response
 */
struct razer_report razer_send_payload(IOUSBDeviceInterface **dev, struct razer_report *request_report) {
    IOReturn retval = -1;
    
    struct razer_report response_report;
    request_report->crc = razer_calculate_crc(request_report);
    
    retval = razer_get_report(dev, request_report, &response_report);
    
    if(retval == kIOReturnSuccess)
    {
        // Check the packet number, class and command are the same
        if(response_report.remaining_packets != request_report->remaining_packets ||
           response_report.command_class != request_report->command_class ||
           response_report.command_id.id != request_report->command_id.id)
        {
            printf("Response doesnt match request\n");
        } else if (response_report.status == RAZER_CMD_BUSY) {
            printf("Device is busy\n");
        } else if (response_report.status == RAZER_CMD_FAILURE) {
            printf("Command failed\n");
        } else if (response_report.status == RAZER_CMD_NOT_SUPPORTED) {
            printf("Command not supported\n");
        } else if (response_report.status == RAZER_CMD_TIMEOUT) {
            printf("Command timed out\n");
        }
    }
    
    return response_report;
}

