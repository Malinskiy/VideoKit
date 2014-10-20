#include "log.h"
#include "stdout.h"
#include <stdio.h>

char buffer[512];

void ffmpeg_log_callback(void* avcl, int level, const char* fmt, va_list vl) {
    if (level > av_log_get_level())
        return;

    sprintf(buffer, fmt, vl);

    callback(level, buffer);
}

