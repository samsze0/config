export def download-m3u8 [url] {
    let u = $url | url parse
    yt-dlp --add-header $"Referer: ($u.scheme)://($u.host)/" --cookies-from-browser chrome -N 8 $"($url)"
}
