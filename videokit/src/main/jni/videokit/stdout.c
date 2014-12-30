#include <jni.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "log.h"

// cached refs for later callbacks
JavaVM * g_vm;
jobject g_obj;
jmethodID g_mid;

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT jboolean JNICALL Java_co_wecommunicate_videokit_Videokit_register(JNIEnv * env, jobject obj) {
	// convert local to global reference
    // (local will die after this method call)
	g_obj = (*env)->NewGlobalRef(env, obj);

	(*env)->GetJavaVM(env, &g_vm);

	// save refs for callback
	jclass g_clazz = (*env)->GetObjectClass(env, g_obj);
	if (g_clazz == NULL) {
		LOGE("Failed to find class");
		return JNI_FALSE;
	}

	g_mid = (*env)->GetMethodID(env, g_clazz, "onLine", "(I[B)V");
	if (g_mid == NULL) {
		LOGE("Unable to get method ref");
		return JNI_FALSE;
	}

	return JNI_TRUE;
}

void callback(int level, const char* value) {
	JNIEnv * g_env;
	// double check it's all ok
	int getEnvStat = (*g_vm)->GetEnv(g_vm, (void **)&g_env, JNI_VERSION_1_6);
	int attached = 0;
	if (getEnvStat == JNI_EDETACHED) {
		if ((*g_vm)->AttachCurrentThread(g_vm, &g_env, NULL) != 0) {
			LOGE("Failed to attach");
		}
		attached = 1;
	} else if (getEnvStat == JNI_OK) {
		//
	} else if (getEnvStat == JNI_EVERSION) {
		LOGE("GetEnv: version not supported");
	}

    const int byteCount = strlen(value);
    jbyte* pNativeMessage = (jbyte*)value;
    jbyteArray bytes = (*g_env)->NewByteArray(g_env, byteCount);
    (*g_env)->SetByteArrayRegion(g_env, bytes, 0, byteCount, pNativeMessage);

	(*g_env)->CallVoidMethod(g_env, g_obj, g_mid, level, bytes);

	(*g_env)->DeleteLocalRef(g_env, bytes);

	if ((*g_env)->ExceptionCheck(g_env)) {
		(*g_env)->ExceptionDescribe(g_env);
	}

	if(attached) (*g_vm)->DetachCurrentThread(g_vm);
}

#ifdef __cplusplus
}
#endif