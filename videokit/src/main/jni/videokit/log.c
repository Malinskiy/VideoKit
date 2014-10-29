#include "log.h"
#include "stdout.h"
#include <stdio.h>
#include <libavutil/log.h>

int print_prefix = 1;

void ffmpeg_log_callback(void* avcl, int level, const char* fmt, va_list vl) {
    if (level > av_log_get_level())
        return;

    va_list vl2;
    va_copy(vl2, vl);
    char* line = (char*)malloc(sizeof(char)*1024);
    av_log_format_line(avcl, level, fmt, vl, line, sizeof(char) * 1024, &print_prefix);
    va_end(vl2);

    callback(level, line);
}

