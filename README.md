# YTall (Downloader Project)

A PowerShell script for conveniently downloading YouTube videos/audio and encoding video into high quality.

---

## 🚀 Getting Started

1.  Place the `run_ytall.ps1` file in a location of your choice (e.g., your desktop).
2.  Right-click the `run_ytall.ps1` file and select **[Run with PowerShell]**.
    -   On first run, the script will automatically create the `ytall` folder and download/install all required files. (The original file is automatically deleted after installation.)
3.  Agree to the legal notice (EULA) by typing `y`, then choose whether to create a desktop shortcut (`y` or `n`) to complete installation.
4.  Once installation finishes, the `README.md` file opens automatically. **(Important: please read it at least once!)**
5.  Add the YouTube links you want to download to `mp3.txt` or `mp4.txt` inside the `ytall` folder and save.
6.  Run the `YTall` shortcut created on your desktop, or `YTall.bat` inside the `ytall` folder, to start downloading.

---

## 🍪 How to Use Cookies (age verification, etc.)

To download videos that require sign-in or age verification, you need to copy your browser's cookie values into the `details/cookies.txt` file. Choose one of the methods below.

**Note:** Cookies may contain sensitive personal information, so never share this file with anyone else.

### Method 1: Using a Browser Extension (Recommended)

The most convenient method is to use an extension that easily exports cookies to a file.

*   **Chrome / Microsoft Edge:**
    (Edge is built on the same base as Chrome, so it supports most extensions from the Chrome Web Store.)
    1.  Install the **[Get cookies.txt LOCALLY](https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc)** extension. (Team lead's recommendation)
    2.  Open the YouTube page you want to get cookies from.
    3.  Click the extension icon (lock shape) next to the address bar, then click **[Export]**.
    4.  The `cookies.txt` file will be downloaded.
    5.  **Copy the entire contents** of the downloaded `cookies.txt` file, then **paste it over (overwrite)** the `cookies.txt` file located in the `ytall/details/` folder and save.

*   **Firefox:**
    1.  Install a cookie-export add-on such as **[cookies.txt](https://addons.mozilla.org/ko/firefox/addon/cookies-txt/)**.
    2.  Open the YouTube page you want to get cookies from.
    3.  Click the cookie-shaped icon next to the address bar, then click **"Download cookies.txt"**.
    4.  The `cookies.txt` file will be downloaded.
    5.  **Copy the entire contents** of the downloaded `cookies.txt` file, then **paste it over (overwrite)** the `cookies.txt` file located in the `ytall/details/` folder and save.

---

### Method 2: Manual Extraction via Developer Tools (if you don't have an extension installed)

#### Extracting Cookies in Chrome / Microsoft Edge

1.  Open the YouTube page containing the video you want to download.
2.  Press **F12** on your keyboard to open **Developer Tools**.
3.  Click the **[Network]** tab.
4.  Refresh the page (**F5**).
5.  Click on an item in the list that starts with `watch?v=`.
6.  In the right pane, select the **[Headers]** tab and scroll to the **Request Headers** section.
7.  Find the `cookie:` entry and copy the entire value.
8.  Paste it into `ytall/details/cookies.txt` and save.

#### Extracting Cookies in Firefox

1.  Open the YouTube page containing the video you want to download.
2.  Press **F12** to open **Developer Tools**.
3.  Click the **[Network]** tab and refresh the page (**F5**).
4.  Click on an item that starts with `watch?v=`.
5.  In the right pane, select the **[Headers]** tab and find **Request Headers**.
6.  Right-click the `Cookie` entry's value and select **[Copy All]**.
7.  Paste it into `ytall/details/cookies.txt` and save.

---

## 🔧 Advanced Settings (config.ini)

You can edit the `details/config.ini` file to control several behaviors of the script.

### [Encoding] Section (encoding-related)
-   **Encoder**: Choose the `gpu` (NVIDIA) or `cpu` encoder. (Automatically falls back to cpu if no NVIDIA graphics card is present.)
-   **Resolution**: Specifies the vertical resolution of the video (e.g., 720, 1080).
-   **MaxRate**: Limits the maximum bitrate during encoding to prevent the file size from becoming excessively large (e.g., 5M, 10M).
-   **GpuCq**: GPU encoding quality (lower = higher quality; recommended: 20-25).
-   **GpuPreset**: GPU encoding speed/quality balance. `p1` (fastest) ~ `p7` (best quality).
-   **CpuCrf**: CPU encoding quality (lower = higher quality; recommended: 22-28).
-   **CpuPreset**: CPU encoding speed/compression ratio. `ultrafast` ~ `veryslow`.

### [General] Section (general settings)
-   **EnableEncoding**: If set to `true`, downloaded MP4 videos are re-encoded with the HEVC (H.265) codec. If set to `false`, the encoding step is skipped and the original downloaded file is used as-is.
-   **ProcessPlaylists**: If set to `true`, when `mp3.txt` or `mp4.txt` contains a playlist link, every video/audio track in the playlist is downloaded. If left as `false`, only the single video from the playlist link itself is downloaded.
    -   **Note:** Once a playlist link has been processed, it is automatically removed from the list file; if some videos failed, only the individual links for those failed videos remain. So if new videos are later added to the playlist, you'll need to re-add the original playlist link to the list file to fetch them.
-   **PlaySoundOnComplete**: If set to `true`, a completion notification sound plays once all jobs are finished.
-   **MinFreeSpaceGB**: Specifies the minimum required free disk space (GB) when the script runs. If available space is less than this, the job is halted for safety.
-   **EmbedThumbnail**: If set to `true`, the video's thumbnail is automatically fetched and embedded as album art when downloading MP3.
-   **EmbedMetadata**: If set to `true`, metadata such as song title, artist, and composer is automatically written inside the MP3 file.
---

## ❤️ Support the Developer (Sponsorship)

If you enjoyed this project, please consider sending the developer a little support. It's a huge help in building better projects!

-   [Support via Ctee](https://ctee.kr/place/rumuk)
