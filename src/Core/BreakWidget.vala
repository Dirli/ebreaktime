namespace EBreakTime.Core {
    public class BreakWidget : Gtk.Window {
        private Gtk.Grid wrapper_grid;
        private Gtk.Label break_left;
        private uint fade_timeout;

        private Gdk.Screen cur_screen;
        private Gtk.Window? sec_window = null;

        private delegate void FadeCompleteCb ();

        public signal void postpone_break ();

        public BreakWidget (bool postpone) {
            Object (
                type: Gtk.WindowType.POPUP,
                modal: true);
            try {
                var provider = new Gtk.CssProvider ();
                provider.load_from_data ("""
                    .break {
                        font-size: 180%;
                        font-weight: 500;
                    }
                """);
                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (Error e) {
                warning ("Error: %s\n", e.message);
            }

            wrapper_grid = new Gtk.Grid ();
            add (wrapper_grid);
            wrapper_grid.show ();
            wrapper_grid.set_halign (Gtk.Align.CENTER);
    		wrapper_grid.set_valign (Gtk.Align.CENTER);
    		cur_screen = get_screen ();
    		cur_screen.composited_changed.connect (on_screen_composited_changed);
    		on_screen_composited_changed (cur_screen);
            realize.connect (on_realize);
    		realize ();

            Gtk.Grid break_ui = new Gtk.Grid ();
            break_ui.row_spacing = 8;

            Gtk.Label break_ui_label = new Gtk.Label (_("Time break"));
            break_ui_label.get_style_context ().add_class ("break");
            break_left = new Gtk.Label ("");
            break_left.get_style_context ().add_class ("break");

            break_ui.attach (break_ui_label, 0, 0);
            break_ui.attach (break_left, 0, 1);

            if (postpone) {
                var postpone_btn = new Gtk.Button.with_label (_("Postpone"));
                break_ui.attach (postpone_btn, 0, 2);
                postpone_btn.halign = Gtk.Align.CENTER;
                postpone_btn.clicked.connect (() => {
                    postpone_break ();
                });
            }

            wrapper_grid.add (break_ui);
            break_ui.show_all ();
        }

        private Gtk.Window overlay_window () {
            Gtk.Window window = new Gtk.Window (Gtk.WindowType.POPUP);

            Gdk.Visual? screen_visual = null;

    		if (cur_screen.is_composited ()) {
    			screen_visual = cur_screen.get_rgba_visual ();
    		}

    		if (screen_visual == null) {
    			screen_visual = cur_screen.get_system_visual ();
    		}

    		window.set_visual (screen_visual);

            return window;
        }

        public void set_break_state (string new_val) {
            break_left.label = new_val;
        }

        private void on_screen_composited_changed (Gdk.Screen screen) {
    		Gdk.Visual? screen_visual = null;

    		if (screen.is_composited ()) {
    			screen_visual = screen.get_rgba_visual ();
    		}

    		if (screen_visual == null) {
    			screen_visual = screen.get_system_visual ();
    		}

    		set_visual (screen_visual);
    	}

        private void on_realize () {
            /* empty input region to ignore any input */
            /* input_shape_combine_region (new Cairo.Region ()); */
            Gdk.Display display = Gdk.Display.get_default ();
            Gdk.Monitor monitor = display.get_monitor_at_window (this.get_window ());
            int display_count = display.get_n_monitors ();

            if (display_count > 1) {
                for (int i = 1; i <= display_count; i++) {
                    Gdk.Monitor? cur_monitor = display.get_monitor (i);

                    if (cur_monitor != null && cur_monitor != monitor) {
                        Gdk.Rectangle geom2 = cur_monitor.get_geometry ();

                        sec_window = overlay_window ();
                        sec_window.set_size_request (geom2.width, geom2.height);
                        sec_window.fullscreen_on_monitor (cur_screen, i);
                        sec_window.show ();
                    }

                }
            }

            Gdk.Rectangle geom = monitor.get_geometry ();

            set_size_request (geom.width, geom.height);
            fade_in ();
        }

        private double ease_swing (double p) {
    		return 0.5 - GLib.Math.cos (p * GLib.Math.PI) / 2.0;
    	}

        private void fade_opacity (double duration_ms, double to, FadeCompleteCb? complete_cb = null) {
    		double from;

    		if (get_visible ()) {
    			from = get_opacity ();
    		} else {
    			from = 0.0;
    			set_opacity (from);
    			show ();
    		}

    		double fade_direction = (double) (to - from);
    		Timer fade_timer = new Timer ();
    		/* if (fade_timeout > 0) {
                Source.remove (fade_timeout);
            } */
    		fade_timeout = GLib.Timeout.add (20, () => {
    			double elapsed_ms = fade_timer.elapsed () * 1000.0;
    			double percent = elapsed_ms / duration_ms;
    			percent = percent.clamp (0, 1);
    			double opacity = from + (fade_direction * ease_swing (percent));
    			set_opacity (opacity);
    			bool do_continue = percent < 1.0;

    			if (! do_continue) {
    				if (complete_cb != null) {
                        complete_cb ();
                    }
    			}

    			return do_continue;
    		});
    	}

        public void fade_in () {
            fade_opacity (2000, 1);
        }

        /* public void fade_out () {
    		if (get_visible ()) {
    			fade_opacity (1500, 0, () => {
    				hide ();
    			});
    		}
    	} */

    	public void fade_out_and_remove () {
    		if (get_visible ()) {
    			fade_opacity (1500, 0, () => {
                    if (sec_window != null) {
                        sec_window.destroy ();
                    }

                    destroy ();
    			});
    		}
    	}
    }
}
