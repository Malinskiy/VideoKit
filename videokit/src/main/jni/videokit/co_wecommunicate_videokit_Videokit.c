

#include <android/log.h>
#include "log.h"
#include "co_wecommunicate_videokit_Videokit.h"

#include <stdlib.h>
#include <stdbool.h>

int main(int argc, char **argv);
extern int received_sigterm;

JavaVM *sVm = NULL;

#define LOG_ERROR(message) __android_log_write(ANDROID_LOG_ERROR, "VideoKit", message)
#define LOG_INFO(message) __android_log_write(ANDROID_LOG_INFO, "VideoKit", message)

int split (const char *str, char c, char ***arr)
{
    int count = 1;
    int token_len = 1;
    int i = 0;
    const char *p;
    char *t;

    p = str;
    while (*p != '\0')
    {
        if (*p == c)
            count++;
        p++;
    }

    *arr = (char**) malloc(sizeof(char*) * count);
    if (*arr == NULL)
        exit(1);

    p = str;
    while (*p != '\0')
    {
        if (*p == c)
        {
            (*arr)[i] = (char*) malloc( sizeof(char) * token_len );
            if ((*arr)[i] == NULL)
                exit(1);

            token_len = 0;
            i++;
        }
        p++;
        token_len++;
    }
    (*arr)[i] = (char*) malloc( sizeof(char) * token_len );
    if ((*arr)[i] == NULL)
        exit(1);

    i = 0;
    p = str;
    t = ((*arr)[i]);
    while (*p != '\0')
    {
        if (*p != c && *p != '\0')
        {
            *t = *p;
            t++;
        }
        else
        {
            *t = '\0';
            i++;
            t = ((*arr)[i]);
        }
        p++;
    }
    *t = '\0';

    return count;
}

JNIEXPORT void JNICALL Java_co_wecommunicate_videokit_Videokit_run(JNIEnv *env, jobject obj, jstring argstring)
{
	int i = 0;
	int argc = 0;
	char **argv = NULL;

	const char *jstr;
	jstr = (*env)->GetStringUTFChars(env, argstring, 0);

	LOGE("%s", jstr);

	argc = split(jstr, ' ', &argv);
	main(argc, argv);

	for(i=0;i<argc;i++)
	{
		free(argv[i]);
	}
	free(argv);
	(*env)->ReleaseStringUTFChars(env, argstring, jstr);
}

JNIEXPORT void JNICALL Java_co_wecommunicate_videokit_Videokit_stop(JNIEnv *env, jobject obj)
{
	received_sigterm++;
}
