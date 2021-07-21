# RaspDac Mini LCD
Toolset and sources file used for customizing RPI audio distributions with RaspDac Mini LCD  hardware support 

This repository holds sources and methods for installing the specific hardware found in a RaspDac Mini LCD (display, remote control) and some utilities in a fresh distribution for audio playback on raspberry pi. 

## Currently supported : 
 
### Volumio
* Installation of LCD Display
* Installation of IR remote
* Installation of aptswi (Tiny web interface with some custom option. It is also used as a server to pass the LCD display template to a Chromium instance).

  
## Important notes : 
* To avoid conflicts it is recommanded to use this toolset on a **fresh** (non-customized) release. 

* It is strongly advised to back-up configuration file and your local music library before installing anything with this toolset.

* Some distros require the audio output to be already configured with the ES9038 driver to work. You should do this in your regular distribution interface **before** running any customization script.
* In the same manner, the LCD display make use of the localui chromium browser to send data to its display.
  * moOde has this option available by default which has to be enabled from the settings menu.
  * Volumio requires the *Touch Display plugin* to be installed and activated. It is best to install the Touch Display Plugin **prior** to this repo since it requires no additionnal configuration. You *can* run this installation script prior to installing the touchscreen pluggin, but you will then have to run the /apts_web_interface/ap_modules/lcd/kiosk_autoconfig.sh bash script afterwards to complete the configuration. You can also trigger the kiosk_autoconfig.sh script via http on the port 4150 if you already applied this repo to your Raspdac Mini LCD. The whole process is quite fast and needs only a couple minutes. 
  * On both moOde and Volumio you can use the 4150 port to rebuild and reconfigure the LCD driver if you want to mess up with the user configuration or the display itself.  
* Remember your device must have network access to download dependencies. **This toolset is not designed for offline installation**.

## Usage : 

* Update package repo list
```bash
sudo apt-get update
```

* Download source files (this repository).
```bash
git clone http://github.com/audiophonics/RaspDacMinilcd
```
* Enter directory.
```bash
cd RaspDacMinilcd
```
* Each supported distribution has its own directory, enter the one corresponding to the distribution installed on your RaspDac Mini LCD. 
```bash
# for Volumio
cd volumio

```
* Run the installation script **as root** to install all available features
```bash
sudo bash install.sh
```

*most scripts deal with hardware configuration and will require you to reboot after completion. A successful script installation will explicitely notify you from terminal if a reboot is needed.*

## Install duration :
Some scripts and core functionnalities automatically download and compile frameworks from source. This is due to the wide range of Linux flavors that are found across the audio distributions for raspberry pi and the different rate at which updates happen. Since the defaults packages and libraries natively available on those systems can vary a lot, do not expect installation time to be consistent from one distribution to another. 

