package co.wecommunicate.videokit;

import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

public final class Videokit {
    private List<OutputListener> listeners = new ArrayList<OutputListener>();

    static {
        System.loadLibrary("videokit");
    }

    {
        register();
    }

    public void addOutputListener(OutputListener listener) {
        listeners.add(listener);
    }

    public void removeOutputListener(OutputListener listener) {
        listeners.remove(listener);
    }

    public native void register();

    public native void run(String args);

    public void onLine(int level, byte[] value) {
        for (int i = 0; i < listeners.size(); i++) {
            listeners.get(i).onString(level, new String(value, Charset.forName("UTF-8")));
        }
    }
}
