package co.wecommunicate.videokit;

import java.security.InvalidParameterException;

public interface OutputListener {
    void onString(int level, String line);

    public static enum LEVEL {
        QUIET(-1),
        PANIC(0),
        FATAL(8),
        ERROR(16),
        WARNING(24),
        INFO(32),
        VERBOSE(40),
        DEBUG(48);

        private int nativeValue;

        LEVEL(int nativeValue) {
            this.nativeValue = nativeValue;
        }

        public LEVEL from(int nativeValue) {
            for(LEVEL value : LEVEL.values()) {
                if(value.nativeValue == nativeValue) return value;
            }
            throw new InvalidParameterException("Unknown log level");
        }
    }
}
