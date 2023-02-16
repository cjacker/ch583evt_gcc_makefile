# ch58x riscv ble evt with gcc and makefile support

This is pre-converted ch58x riscv ble evt firmware library with gcc and makefile support from WCH official CH583EVT.ZIP. 

It is converted by [ch5xx_riscv_ble_evt_makefile_gcc_project_template](https://github.com/cjacker/ch5xx_riscv_ble_evt_makefile_gcc_project_template)

This firmware library support below parts from WCH:

- ch583
- ch582
- ch581

The default part is set to 'ch582', you can change it with `./setpart.sh <part>`. the corresponding 'Link.ld' will update automatically from the template.

The default 'User' codes is not BLE related, just blink a LED on [WeAct ch5xx ble board](https://github.com/WeActStudio/WeActStudio.WCH-BLE-Core). all evt examples shipped in original EVT package provided in 'Examples' dir.

To build the project, type `make`.
