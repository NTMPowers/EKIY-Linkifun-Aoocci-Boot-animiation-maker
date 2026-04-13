# EKIY/Linkifun/Aoocci Boot Animation Maker

A PowerShell script that converts a video clip into an compatible `bootanimation.zip` file, ready to be flashed.

## Compatitble devices
- EKIY M23
- Linkifun MT23
- Aoocci U6
## Requirements

- **Windows** with PowerShell
- **[ffmpeg.exe](https://ffmpeg.org/download.html#build-windows)** — must be placed in the **same folder** as the script

## Usage

```powershell
.\create_bootanimation.ps1 -video <path_to_video> -start <timestamp> [-framecount <1-40>] [-loop <$true|$false>]
```

### Parameters

| Parameter | Required | Default | Description |
|---|---|---|---|
| `-video` | Yes | — | Path to the source video file |
| `-start` | Yes | — | Timestamp to start extracting frames (e.g. `00:00:05`) |
| `-framecount` | No | `40` | Number of frames to extract (1–40) |
| `-loop` | No | `$false` | Whether the animation should loop continuously |

### Example

```powershell
.\create_bootanimation.ps1 -video "C:\clips\intro.mp4" -start "00:00:03" -framecount 30 -loop $true
```

## Output

The script creates a `zqc_tfcard_work\` folder in the script directory containing:

```
zqc_tfcard_work/
└── bootanimation.zip
      ├── part0/
      │   ├── 01.jpg
      │   ├── 02.jpg
      │   └── ...
      └── desc.txt
```

- Frames are extracted at **10 fps**, cropped to a **1:2 ratio**, and scaled to **1440×720**
- The ZIP is stored with **no compression**, as required by the bootanimation format
- `desc.txt` is set to `p 1 0 part0` (play once) or `p 0 0 part0` (loop) based on the `-loop` flag

## logo.bmp
Included example of logo.bmp for KTM 390 Adventure.
Format for logo.bmp is 256-colors BMP, 720 x 1440 pixels.

<div style="text-align:center; margin:0; padding:0;">
  <img src="logo.bmp"
       alt="logo.bmp preview rotated 90 degrees left"
       style="transform: rotate(-90deg); width: 256px; height: auto; image-rendering: pixelated; display:block; margin:0 auto;" />
</div>

## Flashing Instructions

### Flashing `logo.bmp`

1. Format a microSD card as **FAT32**
2. Copy **logo.bmp** to the **root** of the card  
3. Insert the card into the device  
4. Reboot — the device will automatically detect and flash the logo

### Flashing `bootanimation.zip`

1. Format a microSD card as **FAT32**
2. Copy the **entire folder** `zqc_tfcard_work` to the **root** of the card  
   - The structure must be:  
     /zqc_tfcard_work/bootanimation.zip
3. Insert the card into the device  
4. The device will auto‑reboot and apply the new boot animation

**Important:**  
After flashing, remove the files from the SD card to avoid flashing again on the next boot.