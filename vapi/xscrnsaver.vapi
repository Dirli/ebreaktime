[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename="X11/extensions/scrnsaver.h,X11/extensions/saver.h")]
namespace XScreenSaver {
	public enum State {
		[CCode (cname = "ScreenSaverOff")]
		OFF,
		[CCode (cname = "ScreenSaverOn")]
		ON,
		[CCode (cname = "ScreenSaverCycle")]
		CYCLE,
		[CCode (cname = "ScreenSaverDisabled")]
		DISABLED
	}
	[CCode (cname = "ScreenSaverNotifyMask")]
	public const int NotifyMask;
	[CCode (cname = "ScreenSaverCycleMask")]
	public const int CycleMask;
	[CCode (cname = "XScreenSaverNotifyEvent", destroy_function = "", has_type_id = false)]
	public struct NotifyEvent {
		int type;
		ulong serial;
		bool send_event;
		X.Display display;
		X.Window window;
		X.Window root;
		int state;
		int kind;
		bool forced;
		X.Time time;
	}
	[CCode (cname = "XScreenSaverInfo", destroy_function = "", has_type_id = false)]
	public struct Info {
		[CCode (cname = "XScreenSaverAllocInfo")]
		public Info();
		X.Window window;
		int state;
		int kind;
		ulong til_or_since;
		ulong idle;
		ulong eventMask;
	}
	[CCode (cname = "XScreenSaverQueryExtension")]
	public bool query_extension(X.Display display, ref int event_base, ref int error_base);
	[CCode (cname = "XScreenSaverQueryVersion")]
	public X.Status query_version(X.Display display, ref int major_version, ref int minor_version);
	[CCode (cname = "XScreenSaverQueryInfo")]
	public XScreenSaver.Info query_info(X.Display display, X.Drawable drawable);
	[CCode (cname = "XScreenSaverSelectInput")]
	public void select_input(X.Display display, X.Drawable drawable, ulong eventMask);
	[CCode (cname = "XScreenSaverSetAttributes")]
	public void set_attributes(X.Display display, X.Drawable drawable, int x, int y,
	                           uint width, uint height, uint border_width, int depth,
	                           uint class, X.Visual visual, ulong valuemask,
	                           X.SetWindowAttributes attributes
	);
	[CCode (cname = "XScreenSaverUnsetAttributes")]
	public void unset_attributes(X.Display display, X.Drawable drawable);
	[CCode (cname = "XScreenSaverRegister")]
	public X.Status register(X.Display display, int screen, X.ID xid, X.Atom type);
	[CCode (cname = "XScreenSaverUnregister")]
	public X.Status unregister(X.Display display, int screen);
	[CCode (cname = "XScreenSaverGetRegistered")]
	public X.Status get_registered(X.Display display, int screen, X.ID xid, X.Atom type);
	[CCode (cname = "XScreenSaverSuspend")]
	public void suspend(X.Display display, bool suspend);
}
