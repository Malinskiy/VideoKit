LOCAL_PATH := $(call my-dir)

$(warning $(LOCAL_PATH))

include $(CLEAR_VARS)
LOCAL_MODULE := avformat
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libavformat.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avfilter
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libavfilter.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avcodec
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libavcodec.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swscale
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libswscale.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avutil
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libavutil.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avresample
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libavresample.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swresample
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libswresample.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := postproc
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libpostproc.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := vo-aac
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libvo-aacenc.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := fdk-aac
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libfdk-aac.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := x264
LOCAL_SRC_FILES := ffmpeg/$(TARGET_ARCH_ABI)/lib/libx264.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE  := videokit
# These need to be in the right order
FFMPEG_LIBS := $(addprefix ffmpeg/, \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libavformat.a \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libavresample.a \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libavfilter.a \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libavcodec.a \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libswscale.a \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libavutil.a \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libswresample.a \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libpostproc.a \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libfdk-aac.a \
 ffmpeg/$(TARGET_ARCH_ABI)/lib/libvo-aacenc.a)
# ffmpeg uses its own deprecated functions liberally, so turn off that annoying noise
LOCAL_CFLAGS += -g -Iffmpeg -Ivideokit -Wno-deprecated-declarations 
LOCAL_LDLIBS += -llog -lz
LOCAL_STATIC_LIBRARIES := avformat avresample avfilter avcodec swscale avutil swresample postproc vo-aac fdk-aac x264
LOCAL_SRC_FILES :=  videokit/cmdutils.c videokit/ffmpeg.c videokit/ffmpeg_opt.c videokit/ffmpeg_filter.c videokit/uk_co_halfninja_videokit_Videokit.c
LOCAL_C_INCLUDES += $(LOCAL_PATH)/ffmpeg/$(TARGET_ARCH_ABI)/include
include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)
LOCAL_MODULE := videokitinvoke
LOCAL_SRC_FILES := videokitinvoke/videokitinvoke.c
LOCAL_LDLIBS    := -ldl -llog
include $(BUILD_SHARED_LIBRARY)




