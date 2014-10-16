package co.wecommunicate.videokit;

public final class Videokit {

  static {
    System.loadLibrary("videokit");
  }

  public native void run(String[] args);

}
